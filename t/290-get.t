#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 10;


can_ok(
	'DBIx::NinjaORM',
	'get',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get',
);

ok(
	defined(
		my $test = DBIx::NinjaORM::Test->new(),
	),
	'Create a new Test object.',
);

dies_ok(
	sub
	{
		$test->get();
	},
	'A field name is mandatory.',
);

dies_ok(
	sub
	{
		$test->get('');
	},
	'An empty field name is not valid.',
);

ok(
	defined( $test->{'_field'} = 1 ),
	'Set up field starting with an underscore.',
);

dies_ok(
	sub
	{
		$test->get('_field');
	},
	'Fields starting with an underscore cannot be retrieved via get().',
);

ok(
	defined( $test->{'field'} = 10 ),
	'Set up a normal field.',
);

my $value;
lives_ok(
	sub
	{
		$value = $test->get('field');
	},
	"Retrieve the field's value.",
);

is(
	$value,
	10,
	'The value retrieved matches the value set up.',
);


package DBIx::NinjaORM::Test;

use strict;
use warnings;

use lib 't';
use LocalTest;

use base 'DBIx::NinjaORM';

1;

__DATA__

sub static_class_info
{
	my ( $class ) = @_;
	
	my $info = $class->SUPER::static_class_info();
	
	$info->{'default_dbh'} = LocalTest::get_database_handle();
	$info->{'table_name'} = 'tests';
	$info->{'primary_key_name'} = 'test_id';
	$info->{'filtering_fields'} = [ 'name' ];
	
	return $info;
}

1;

