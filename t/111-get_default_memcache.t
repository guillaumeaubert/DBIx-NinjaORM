#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 4;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'get_memcache',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_memcache',
);

my $tests =
[
	{
		name => 'Test calling get_memcache() on the class',
		ref  => 'DBIx::NinjaORM::Test',
	},
	{
		name => 'Test calling get_memcache() on an object',
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


package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'memcache' => "TESTMEMCACHE",
	};
}

1;
