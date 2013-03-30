#!perl -T

=head1 PURPOSE

Make sure that get_readonly_fields() returns the arrayref of read-only fields
specified in the static class information.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Test::More tests => 5;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'get_readonly_fields',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_readonly_fields',
);

# Tests.
my $tests =
[
	{
		name     => 'Test calling get_readonly_fields() on DBIx::NinjaORM',
		ref      => 'DBIx::NinjaORM',
		expected => [],
	},
	{
		name     => 'Test calling get_readonly_fields() on DBIx::NinjaORM::Test',
		ref      => 'DBIx::NinjaORM::Test',
		expected => [ 'test' ],
	},
	{
		name     => 'Test calling get_readonly_fields() on an object',
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
			
			my $readonly_fields;
			lives_ok(
				sub
				{
					$readonly_fields = $test->{'ref'}->get_readonly_fields();
				},
				'Retrieve the list cache time.',
			);
			
			is_deeply(
				$readonly_fields,
				$test->{'expected'},
				'get_readonly_fields() returns the value set up in static_class_info().',
			);
		}
	);
}


# Test subclass with 'readonly_fields' set.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'readonly_fields' => [ 'test' ],
	};
}

1;
