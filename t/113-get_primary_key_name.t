#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 4;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'get_primary_key_name',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_primary_key_name',
);

my $tests =
[
	{
		name => 'Test calling get_primary_key_name() on the class',
		ref  => 'DBIx::NinjaORM::Test',
	},
	{
		name => 'Test calling get_primary_key_name() on an object',
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
			
			my $primary_key_name;
			lives_ok(
				sub
				{
					$primary_key_name = $test->{'ref'}->get_primary_key_name();
				},
				'Retrieve the primary key name.',
			);
			
			is(
				$primary_key_name,
				'TEST_PRIMARY_KEY_NAME',
				'get_primary_key_name() returns the value set up in static_class_info().',
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
		'primary_key_name' => "TEST_PRIMARY_KEY_NAME",
	};
}

1;
