#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 5;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'new',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'new',
);

my $object;
lives_ok(
	sub
	{
		$object = DBIx::NinjaORM::Test->new();
	},
	'Instantiate an empty object.',
);

isa_ok(
	$object,
	'DBIx::NinjaORM::Test',
);

is(
	scalar( keys %$object),
	0,
	'The object is empty.',
);


package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'unique_fields'    => [],
		'primary_key_name' => 'test_pk',
	};
}

1;
