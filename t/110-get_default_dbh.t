#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 4;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'get_default_dbh',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_default_dbh',
);

my $tests =
[
	{
		name => 'Test calling get_default_dbh() on the class',
		ref  => 'DBIx::NinjaORM::Test',
	},
	{
		name => 'Test calling get_default_dbh() on an object',
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
			
			my $default_dbh;
			lives_ok(
				sub
				{
					$default_dbh = $test->{'ref'}->get_default_dbh();
				},
				'Retrieve the default database handle.',
			);
			
			is(
				$default_dbh,
				'TESTDBH',
				'get_default_dbh() returns the value set up in static_class_info().',
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
		'default_dbh' => "TESTDBH",
	};
}

1;
