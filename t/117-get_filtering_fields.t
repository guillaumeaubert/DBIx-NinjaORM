#!perl -T

=head1 PURPOSE

Make sure that get_filtering_fields() returns the arrayref of filtering fields
specified in the static class information.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 6;
use Test::NoWarnings;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'get_filtering_fields',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_filtering_fields',
);

# Tests.
my $tests =
[
	{
		name     => 'Test calling get_filtering_fields() on DBIx::NinjaORM',
		ref      => 'DBIx::NinjaORM',
		expected => [],
	},
	{
		name     => 'Test calling get_filtering_fields() on DBIx::NinjaORM::Test',
		ref      => 'DBIx::NinjaORM::Test',
		expected => [ 'test' ],
	},
	{
		name     => 'Test calling get_filtering_fields() on an object',
		ref      => bless( {}, 'DBIx::NinjaORM::Test' ),
		expected => [ 'test' ],
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
			
			my $filtering_fields;
			lives_ok(
				sub
				{
					$filtering_fields = $test->{'ref'}->get_filtering_fields();
				},
				'Retrieve the list cache time.',
			);
			
			is_deeply(
				$filtering_fields,
				$test->{'expected'},
				'get_filtering_fields() returns the value set up in static_class_info().',
			);
		}
	);
}


# Test subclass with 'filtering_fields' set.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'filtering_fields' => [ 'test' ],
	};
}

1;
