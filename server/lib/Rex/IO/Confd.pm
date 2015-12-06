package Rex::IO::Confd;
use Mojo::Base 'Mojolicious';

use Rex::IO::Confd::Schema;

has schema => sub {
  my ($self) = @_;

  my $dsn;

  if ( exists $self->config->{database}->{dsn} ) {
    $dsn = $self->config->{database}->{dsn};
  }
  else {
    $dsn =
        "dbi:"
      . $self->config->{database}->{type} . ":"
      . "database="
      . $self->config->{database}->{schema} . ";" . "host="
      . $self->config->{database}->{host};
  }

  return Rex::IO::Confd::Schema->connect(
    $dsn,
    ( $self->config->{database}->{username} || "" ),
    ( $self->config->{database}->{password} || "" ),
    ( $self->config->{database}->{options}  || {} ),
  );
};

our $VERSION = "0.6.0";

sub startup {
  my $self = shift;

  #######################################################################
  # Define some custom helpers
  #######################################################################
  $self->helper( db => sub { $self->app->schema } );

  #######################################################################
  # Load configuration
  #######################################################################
  my @cfg = (
    "/etc/rex/io/confd_server.conf",
    "/usr/local/etc/rex/io/confd_server.conf",
    "confd_server.conf"
  );
  my $cfg;
  for my $file (@cfg) {
    if ( -f $file ) {
      $cfg = $file;
      last;
    }
  }

  #######################################################################
  # Load plugins
  #######################################################################
  $self->plugin( "Config", file => $cfg );

  #######################################################################
  # Load routes
  #######################################################################
  my $r = $self->routes;

  $r->get('/api/v1/')->to('api#index');

  $r->get('/api/v1/:db/:collection/*key')->to('api#get_key');
  $r->put('/api/v1/:db/:collection/*key')->to('api#put_key');

  $r->get('/')->to(
    cb => sub {
      shift->render( text => 'Not found.' );
    }
  );
  $r->get('/*all')->to(
    cb => sub {
      shift->render( text => 'Not found.' );
    }
  );

  #######################################################################
  # Register to Rex.IO
  #######################################################################
  my $ua = Mojo::UserAgent->new;
  my $me = $self->config->{"rex.io"}->{me};
  my $rex_io_server = $self->config->{"rex.io"}->{url};
  my $register_conf = {
    name => "confd",
    methods => [
      {
        url => "/:db/:collection/*key",
        meth => "GET",
        auth => 0,
        location => "$me/api/v1/:db/:collection/*key",
      },
      {
        url => "/:db/:collection/*key",
        meth => "PUT",
        auth => 0,
        location => "$me/api/v1/:db/:collection/*key",
      },
    ],
  };
  
  $ua->post("$rex_io_server/1.0/plugin/plugin", json => $register_conf);
}

1;
