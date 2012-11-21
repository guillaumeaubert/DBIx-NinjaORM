#!perl -T

=head1 PURPOSE

Test retrieve_list_nocache(), which is how we turn SELECTs into objects without
any caching involved.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 6;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'retrieve_list_nocache',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'retrieve_list_nocache',
);

dies_ok(
	sub
	{
		DBIx::NinjaORM::Test->retrieve_list_nocache(
			{
				value => 'value',
			},
		);
	},
	'Detect fields that are not listed as allowing filtering.',
);

dies_ok(
	sub
	{
		DBIx::NinjaORM::Test->retrieve_list_nocache(
			{},
		);
	},
	'Require at least one filtering criteria by default.',
);

dies_ok(
	sub
	{
		DBIx::NinjaORM::Test->retrieve_list_nocache(
			{},
			allow_all => 0,
		);
	},
	'Require at least one filtering criteria unless allow_all=1.',
);

lives_ok(
	sub
	{
		DBIx::NinjaORM::Test->retrieve_list_nocache(
			{},
			allow_all => 1,
		);
	},
	'No filtering criteria works with allow_all=1.',
);


# Test subclass.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use lib 't/lib';
use LocalTest;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	my ( $class ) = @_;
	
	my $info = $class->SUPER::static_class_info();
	
	$info->{'default_dbh'} = LocalTest::get_database_handle();
	$info->{'table_name'} = 'tests';
	$info->{'primary_key_name'} = 'test_id';
	$info->{'filtering_fields'} = [ 'name' ];
	
	return $info;
}

1;
