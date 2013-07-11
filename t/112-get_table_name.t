#!perl -T

=head1 PURPOSE

Make sure that get_table_name() returns the table name specified in the static
class information.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Test::More tests => 4;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'get_table_name',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_table_name',
);

# Tests.
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

# Run tests.
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


# Test subclass with a table name.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	my ( $class ) = @_;
	
	my $info = $class->SUPER::static_class_info();
	
	$info->set(
		{
			'table_name' => "TEST_TABLE_NAME",
		}
	);
	
	return $info;
}

1;
