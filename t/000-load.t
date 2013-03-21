#!perl -T

=head1 PURPOSE

Test that DBIx::NinjaORM loads.

=cut

use Test::More tests => 3;
use Test::NoWarnings;


BEGIN
{
	use_ok( 'DBI' );
	use_ok( 'DBIx::NinjaORM' );
}

diag( "Testing DBIx::NinjaORM $DBIx::NinjaORM::VERSION, Perl $], $^X" );
