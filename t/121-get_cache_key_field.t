#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 5;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'get_cache_key_field',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_cache_key_field',
);

my $tests =
[
	{
		name     => 'Test calling get_cache_key_field() on DBIx::NinjaORM',
		ref      => 'DBIx::NinjaORM',
		expected => undef,
	},
	{
		name     => 'Test calling get_cache_key_field() on DBIx::NinjaORM::Test',
		ref      => 'DBIx::NinjaORM::Test',
		expected => 'TEST_CACHE_KEY_FIELD',
	},
	{
		name     => 'Test calling get_cache_key_field() on an object',
		ref      => bless( {}, 'DBIx::NinjaORM::Test' ),
		expected => 'TEST_CACHE_KEY_FIELD',
	},
];

foreach my $test ( @$tests )
{
	subtest(
		$test->{'name'},
		sub
		{
			plan( tests => 2 );
			
			my $cache_key_field;
			lives_ok(
				sub
				{
					$cache_key_field = $test->{'ref'}->get_cache_key_field();
				},
				'Retrieve the list cache time.',
			);
			
			is(
				$cache_key_field,
				$test->{'expected'},
				'get_cache_key_field() returns the value set up in static_class_info().',
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
		'cache_key_field' => 'TEST_CACHE_KEY_FIELD',
	};
}

1;