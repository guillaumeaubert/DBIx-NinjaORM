#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 5;


can_ok(
	'DBIx::NinjaORM',
	'get_unique_fields',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_unique_fields',
);

my $tests =
[
	{
		name     => 'Test calling get_unique_fields() on DBIx::NinjaORM',
		ref      => 'DBIx::NinjaORM',
		expected => [],
	},
	{
		name     => 'Test calling get_unique_fields() on DBIx::NinjaORM::Test',
		ref      => 'DBIx::NinjaORM::Test',
		expected => [ 'test' ],
	},
	{
		name     => 'Test calling get_unique_fields() on an object',
		ref      => bless( {}, 'DBIx::NinjaORM::Test' ),
		expected => [ 'test' ],
	},
];

foreach my $test ( @$tests )
{
	subtest(
		$test->{'name'},
		sub
		{
			plan( tests => 2 );
			
			my $unique_fields;
			lives_ok(
				sub
				{
					$unique_fields = $test->{'ref'}->get_unique_fields();
				},
				'Retrieve the list cache time.',
			);
			
			is_deeply(
				$unique_fields,
				$test->{'expected'},
				'get_unique_fields() returns the value set up in static_class_info().',
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
		'unique_fields' => [ 'test' ],
	};
}

1;
