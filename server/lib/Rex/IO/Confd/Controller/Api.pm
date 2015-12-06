package Rex::IO::Confd::Controller::Api;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use Data::Diver qw(DiveVal);

use Config::Properties;
use YAML;

sub index {
  my $self = shift;

  $self->render(
    json => {
      version => '1.0',
    }
  );
}

sub get_key {
  my $self = shift;
  my $db   = $self->param("db");
  my $coll = $self->param("collection");
  my $key  = $self->param("key");

  $self->app->log->debug("Query DB for key: $db/$coll/$key");

  $key .= "/" if $key !~ m/\/$/;

  my $full_key = "$db/$coll/$key";
  my $cursor   = $self->db->resultset("Entry")->search(
    {
      id => { -like => "$full_key\%" },
    }
  );

  my $ret = {};

  # convert documents into one nested doc
  my $current_time = time();
  while ( my $entry = $cursor->next ) {
    my $id = $entry->id;
    
    if($entry->ttl == 0 || ( $entry->ttl > 0 && ($entry->ttl + $entry->created) > $current_time )) {
      $self->app->log->debug("Key ($full_key) has a valid ttl.");

      $id =~ s/^\Q$full_key\E//;
      DiveVal( $ret //= {}, split /\//, $id ) = $entry->value;
    }
  }

  $self->respond_to(
    any  => { json => $ret },
    yaml => sub {
      $self->res->headers->content_type("text/yaml");
      $self->render( text => YAML::Dump($ret) );
    },
    properties => sub {
      $self->res->headers->content_type("text/x-java-properties");
      my $p = Config::Properties->new;
      $p->setFromTree($ret);
      $self->render( text => $p->saveToString() );
    },

  );
}

sub put_key {
  my $self = shift;
  my $db   = $self->param("db");
  my $coll = $self->param("collection");
  my $key  = $self->param("key");
  my $ref  = $self->req->json;

  $self->app->log->debug("Writing to key: $db/$coll/$key = ");
  $self->app->log->debug( Dumper($ref) );

  my $opts = {
    created => scalar time(),    
  };
  
  for my $key (keys %{ $ref }) {
    # keys beginning with underscore are internal keys.
    if($key =~ m/^_/) {
      $opts->{substr($key, 1)} = $ref->{$key};
      delete $ref->{$key};
    }
  }

  eval {
    $self->_store_key( $key, $ref, $opts );
    $self->render( json => { ok => Mojo::JSON->true } );
    1;
  } or do {
    $self->render(
      json   => { ok => Mojo::JSON->false, error => $@ },
      status => 500
    );
  };
}

sub _store_key {
  my ( $self, $key, $value, $opts ) = @_;

  my $db   = $self->param("db");
  my $coll = $self->param("collection");

  if ( ref $value eq "HASH" ) {
    for my $s_key ( keys %{$value} ) {
      $self->_store_key( "$key/$s_key", $value->{$s_key}, $opts );
    }
    return;
  }
  elsif ( ref $value eq "ARRAY" ) {
    my $i = 0;
    for my $s_val ( @{$value} ) {
      $self->_store_key( "$key/$i", $s_val, $opts );
      $i++;
    }
    return;
  }
  else {
    $key .= "/" if $key !~ m/\/$/;

    $self->db->resultset("Entry")->create(
      {
        id         => "$db/$coll/$key",
        value      => $value,
        created    => $opts->{current_time},
        ttl        => $opts->{ttl} // 0,
        check_url  => $opts->{check_url},
        check_freq => $opts->{check_freq},
        check_flap => $opts->{check_flap},
      }
    );
  }
}

1;
