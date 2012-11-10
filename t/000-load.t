#!perl -T

use Test::More tests => 2;

BEGIN
{
	use_ok( 'DBI' );
	use_ok( 'DBIx::NinjaORM' );
}

diag( "Testing DBIx::NinjaORM $DBIx::NinjaORM::VERSION, Perl $], $^X" );
