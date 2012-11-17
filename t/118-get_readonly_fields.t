#!perl -T

=head1 PURPOSE

Make sure that get_private_fields() returns the arrayref of private fields
specified in the static class information.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 5;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'get_private_fields',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_private_fields',
);

# Tests.
my $tests =
[
	{
		name     => 'Test calling get_private_fields() on DBIx::NinjaORM',
		ref      => 'DBIx::NinjaORM',
		expected => [],
	},
	{
		name     => 'Test calling get_private_fields() on DBIx::NinjaORM::Test',
		ref      => 'DBIx::NinjaORM::Test',
		expected => [ 'test' ],
	},
	{
		name     => 'Test calling get_private_fields() on an object',
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
			
			my $private_fields;
			lives_ok(
				sub
				{
					$private_fields = $test->{'ref'}->get_private_fields();
				},
				'Retrieve the list cache time.',
			);
			
			is_deeply(
				$private_fields,
				$test->{'expected'},
				'get_private_fields() returns the value set up in static_class_info().',
			);
		}
	);
}


# Test subclass with 'private_fields' set.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'private_fields' => [ 'test' ],
	};
}

1;
