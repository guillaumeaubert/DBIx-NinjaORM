#!perl -T

=head1 PURPOSE

Test that insert() accepts a specific 'created' timestamp, via the
'overwrite_created' parameter.

=cut

use strict;
use warnings;

use lib 't/lib';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 7;
use Test::Type;


my $dbh = LocalTest::ok_database_handle();

ok(
	defined(
		my $name = "test_overwrite_created_" . time()
	),
	'Create test field name.',
);

ok(
	defined(
		my $insert_time = time() - 2 * 7200
	),
	'Forge insert time in the past.',
);

ok(
	defined(
		my $object = DBIx::NinjaORM::Test->new()
	),
	'Create a new object.',
);

# Insert row.
lives_ok(
	sub
	{
		$object->insert(
			{
				name  => $name,
				value => 1,
			},
			overwrite_created => $insert_time,
		);
	},
	'Insert a test record with "overwrite_created" set.',
);

# Verify that the row was inserted with the custom 'created' time.
my $row;
lives_ok(
	sub
	{
		$row = $dbh->selectrow_hashref(
			q|
				SELECT created
				FROM tests
				WHERE name = ?
			|,
			{},
			$name,
		);
		
		die 'No row'
			if !defined( $row );
	},
	'Retrieve the inserted row',
);

is(
	$row->{'created'},
	$insert_time,
	'The created time is correct.',
);


# Test subclass with enough information to successfully insert rows.
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
	
	return $info;
}

1;
