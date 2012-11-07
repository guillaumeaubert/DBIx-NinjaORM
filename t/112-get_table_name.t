#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 4;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'get_table_name',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_table_name',
);

my $tests =
[
	{
		name => 'Test calling get_table_name() on the class',
		ref  => 'DBIx::NinjaORM::Test',
	},
	{
		name => 'Test calling get_table_name() on an object',
		ref  => bless( {}, 'DBIx::NinjaORM::Test' ),
	},
];

foreach my $test ( @$tests )
{
	subtest(
		$test->{'name'},
		sub
		{
			plan( tests => 2 );
			
			my $table_name;
			lives_ok(
				sub
				{
					$table_name = $test->{'ref'}->get_table_name();
				},
				'Retrieve the table name.',
			);
			
			is(
				$table_name,
				'TEST_TABLE_NAME',
				'get_table_name() returns the value set up in static_class_info().',
			);
		}
	);
}


package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'table_name' => "TEST_TABLE_NAME",
	};
}

1;
