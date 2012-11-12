#!perl -T

=head1 PURPOSE

Make sure that get_memcache() returns the memcache object specified in the
static class information.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 4;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'get_memcache',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_memcache',
);

# Tests.
my $tests =
[
	# We need to support $class->get_memcache() calls.
	{
		name => 'Test calling get_memcache() on the class',
		ref  => 'DBIx::NinjaORM::Test',
	},
	# We need to support $object->get_memcache() calls.
	{
		name => 'Test calling get_memcache() on an object',
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
			
			my $memcache;
			lives_ok(
				sub
				{
					$memcache = $test->{'ref'}->get_memcache();
				},
				'Retrieve memcache object.',
			);
			
			is(
				$memcache,
				'TESTMEMCACHE',
				'get_memcache() returns the value set up in static_class_info().',
			);
		}
	);
}


# Test subclass with a custom 'memcache' key.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		# We're not going to use the memcache object, we just need to
		# be able to make sure that get_memcache() returns this value,
		# so it's easier here to set it here to a known value than to
		# compare memory addresses.
		'memcache' => "TESTMEMCACHE",
	};
}

1;
