#!perl -T

=head1 PURPOSE

Test the clone() method.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Test::More tests => 11;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'clone',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'clone',
);

# Insert an object we'll use for tests here.
my $object_id;
subtest(
	'Insert a new object.',
	sub
	{
		plan( tests => 2 );
		
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
						name => 'test_clone_' . time(),
					}
				)
			},
			'Insert succeeds.',
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

# Clone the object.
my $cloned_object;
lives_ok(
	sub
	{
		$cloned_object = $object->clone();
	},
	'Clone the object.',
);

# Make sure the clone is still a hashref.
ok_hashref(
	$cloned_object,
	name => 'The cloned object',
);

# Make sure the clone has the correct blessing.
isa_ok(
	$cloned_object,
	'DBIx::NinjaORM::Test',
	'The cloned object'
);

# Make sure the objects match.
is_deeply(
	$cloned_object,
	$object,
	'The data structure is identical for the object and its clone.',
) || diag( explain( "Object: ", $object, "Cloned object: ", $cloned_object ) );

# Make sure the objects don't point to the same memory location.
isnt(
	$cloned_object,
	$object,
	'The object and its clone point to different memory locations.',
);

# Test modifying the cloned object, and make sure the modifications don't
# replicate over to the original object.
ok(
	$object->{'account_id'} = 10,
	'Modify the account_id field on the object.',
);
is(
	$cloned_object->{'account_id'},
	undef,
	'The original object is unchanged.',
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

