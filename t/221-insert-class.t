#!perl -T

=head1 PURPOSE

Test inserting rows without an object, by using the insert() method directly on
a class.

=cut

use strict;
use warnings;

use lib 't/lib';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 6;
use Test::NoWarnings;


my $dbh = LocalTest::ok_database_handle();

ok(
	defined(
		my $name = "test_" . time()
	),
	'Create test field name.',
);

# Insert directly from the class, with $class->insert() instead
# of $object->insert().
lives_ok(
	sub
	{
		DBIx::NinjaORM::Test->insert(
			{
				name  => $name,
				value => 1,
			}
		)
	},
	'Insert a test record using the class name.',
);

# Verify that the insert worked.
my $row;
lives_ok(
	sub
	{
		$row = $dbh->selectrow_hashref(
			q|
				SELECT *
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
	$row->{'value'},
	1,
	'The row was properly inserted.',
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
	return
	{
		'default_dbh'      => LocalTest::get_database_handle(),
		'table_name'       => 'tests',
		'primary_key_name' => 'test_id',
	};
}

1;
