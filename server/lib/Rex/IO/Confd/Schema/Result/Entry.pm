#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Confd::Schema::Result::Entry;

use strict;
use warnings;

use base qw(DBIx::Class::Core);

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);
__PACKAGE__->table("entries");
__PACKAGE__->add_columns(
    id => {
        data_type  => 'varchar',
        is_numeric => 0,
        size       => 500,
        is_nullable => 0,
    },
    value => {
        data_type   => 'varchar',
        size        => 5000,
    },
    ttl => {
        data_type   => 'integer',
        is_numeric  => 1,
        default     => 0,
        is_nullable => 1,
    },
    created => {
        data_type   => 'integer',
        is_numeric  => 1,
        default     => 0,
        is_nullable => 1,
    },
    check_url => {
        data_type   => 'varchar',
        is_numeric  => 0,
        default     => "",
        is_nullable => 1,
    },
    check_freq => {
        data_type   => 'integer',
        is_numeric  => 1,
        default     => 3,
        is_nullable => 1,
    },
    check_flap => {
        data_type   => 'integer',
        is_numeric  => 1,
        default     => 5,
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key("id");

1;
