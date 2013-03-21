#!perl -T

=head1 PURPOSE

Make sure that get_object_cache_time() returns the object cache time specified
in the static class information.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 6;
use Test::NoWarnings;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'get_object_cache_time',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_object_cache_time',
);

# Tests.
my $tests =
[
	{
		name     => 'Test calling get_object_cache_time() on DBIx::NinjaORM',
		ref      => 'DBIx::NinjaORM',
		expected => undef,
	},
	{
		name     => 'Test calling get_object_cache_time() on DBIx::NinjaORM::Test',
		ref      => 'DBIx::NinjaORM::Test',
		expected => 20,
	},
	{
		name     => 'Test calling get_object_cache_time() on an object',
		ref      => bless( {}, 'DBIx::NinjaORM::Test' ),
		expected => 20,
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
			
			my $object_cache_time;
			lives_ok(
				sub
				{
					$object_cache_time = $test->{'ref'}->get_object_cache_time();
				},
				'Retrieve the list cache time.',
			);
			
			is(
				$object_cache_time,
				$test->{'expected'},
				'get_object_cache_time() returns the value set up in static_class_info().',
			);
		}
	);
}


# Test subclass with object_cache_time set.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'object_cache_time' => 20,
	};
}

1;
