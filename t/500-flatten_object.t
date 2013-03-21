#!perl -T

=head1 PURPOSE

Test the flatten_object() method.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 8;
use Test::NoWarnings;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'flatten_object',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'flatten_object',
);

# Insert an object we'll use for tests here.
my $object_id;
subtest(
	'Test id() after inserting an object.',
	sub
	{
		plan( tests => 3 );
		
		ok(
			defined(
				my $object = DBIx::NinjaORM::Test->new()
			),
			'Create new object.',
		);
		
		lives_ok(
			sub
			{
				$object->insert(
					{
						name => 'test_flatten_' . time(),
					}
				)
			},
			'Insert succeeds.',
		);
		
		isnt(
			$object->id(),
			undef,
			'id() returns a defined value.',
		);
		
		$object_id = $object->id();
	}
);

# Retrieve object.
ok(
	defined(
		my $object = DBIx::NinjaORM::Test->new(
			{ id => $object_id },
		)
	),
	'Retrieve the object previously inserted.',
);

# List of keys to flatten.
my $flatten_keys = 
[
	qw(
		name
		test_id
	)
];

# Flatten.
my $flattened_object;
lives_ok(
	sub
	{
		$flattened_object = $object->flatten_object(
			$flatten_keys
		);
	},
	'Flatten the object.',
);

ok_hashref(
	$flattened_object,
	name => 'The flattened object.',
);

cmp_deeply(
	[ sort keys %$flattened_object ],
	$flatten_keys,
	'The output of flatten() matches the requested fields.',
);


# Test subclass with enough information to insert rows.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use lib 't/lib';
use LocalTest;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	my ( $class ) = @_;
	
	my $info = $class->SUPER::static_class_info();
	
	$info->{'default_dbh'} = LocalTest::get_database_handle();
	$info->{'table_name'} = 'tests';
	$info->{'primary_key_name'} = 'test_id';
	
	return $info;
}

1;
