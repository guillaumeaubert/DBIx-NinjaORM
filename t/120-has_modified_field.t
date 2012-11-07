#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 8;


can_ok(
	'DBIx::NinjaORM',
	'has_modified_field',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::TestCreated',
	'has_modified_field',
);
can_ok(
	'DBIx::NinjaORM::TestNoCreated',
	'has_modified_field',
);

my $tests =
[
	{
		name     => 'Test calling has_modified_field() on DBIx::NinjaORM.',
		ref      => 'DBIx::NinjaORM',
		expected => 1,
	},
	{
		name     => 'Test calling has_modified_field() on DBIx::NinjaORM::TestCreated.',
		ref      => 'DBIx::NinjaORM::TestCreated',
		expected => 1,
	},
	{
		name     => 'Test calling has_modified_field() on a DBIx::NinjaORM::TestCreated object.',
		ref      => bless( {}, 'DBIx::NinjaORM::TestCreated' ),
		expected => 1,
	},
	{
		name     => 'Test calling has_modified_field() on DBIx::NinjaORM::TestNoCreated.',
		ref      => 'DBIx::NinjaORM::TestNoCreated',
		expected => 0,
	},
	{
		name     => 'Test calling has_modified_field() on a DBIx::NinjaORM::TestNoCreated object.',
		ref      => bless( {}, 'DBIx::NinjaORM::TestNoCreated' ),
		expected => 0,
	},
];

foreach my $test ( @$tests )
{
	subtest(
		$test->{'name'},
		sub
		{
			plan( tests => 2 );
			
			my $modified_field;
			lives_ok(
				sub
				{
					$modified_field = $test->{'ref'}->has_modified_field();
				},
				'Retrieve the list cache time.',
			);
			
			is(
				$modified_field,
				$test->{'expected'},
				'has_modified_field() returns the value set up in static_class_info().',
			);
		}
	);
}


package DBIx::NinjaORM::TestCreated;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'has_modified_field' => 1,
	};
}

1;


package DBIx::NinjaORM::TestNoCreated;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'has_modified_field' => 0,
	};
}

1;
