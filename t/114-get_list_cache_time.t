#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 5;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'get_list_cache_time',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_list_cache_time',
);

my $tests =
[
	{
		name     => 'Test calling get_list_cache_time() on DBIx::NinjaORM',
		ref      => 'DBIx::NinjaORM',
		expected => undef,
	},
	{
		name     => 'Test calling get_list_cache_time() on DBIx::NinjaORM::Test',
		ref      => 'DBIx::NinjaORM::Test',
		expected => 20,
	},
	{
		name     => 'Test calling get_list_cache_time() on an object',
		ref      => bless( {}, 'DBIx::NinjaORM::Test' ),
		expected => 20,
	},
];

foreach my $test ( @$tests )
{
	subtest(
		$test->{'name'},
		sub
		{
			plan( tests => 2 );
			
			my $list_cache_time;
			lives_ok(
				sub
				{
					$list_cache_time = $test->{'ref'}->get_list_cache_time();
				},
				'Retrieve the list cache time.',
			);
			
			is(
				$list_cache_time,
				$test->{'expected'},
				'get_list_cache_time() returns the value set up in static_class_info().',
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
		'list_cache_time' => 20,
	};
}

1;
