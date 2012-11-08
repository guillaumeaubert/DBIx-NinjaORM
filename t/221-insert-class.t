#!perl -T

use strict;
use warnings;

use lib 't';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 5;
use Test::Type;


my $dbh = LocalTest::ok_database_handle();

ok(
	defined(
		my $name = "test_" . time()
	),
	'Create test field name.',
);

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


package DBIx::NinjaORM::Test;

use strict;
use warnings;

use lib 't';
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
