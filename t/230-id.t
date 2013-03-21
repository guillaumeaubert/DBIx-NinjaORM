#!perl -T

=head1 PURPOSE

Test the id() method, which is a shortcut to get the value of the primary key
for a given object.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 5;
use Test::NoWarnings;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'id',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'id',
);

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
						name => 'test_id_' . time(),
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

subtest(
	'Test id() after retrieve_list().',
	sub
	{
		plan( tests => 3 );
		
		ok(
			defined(
				my $objects = DBIx::NinjaORM::Test->retrieve_list(
					{
						id => $object_id,
					}
				)
			),
			'Retrieve the object previously inserted.',
		);
		
		is(
			scalar( @$objects ),
			1,
			'Found object.',
		);
		
		is(
			$objects->[0]->id(),
			$object_id,
			'id() on the retrieved object matches the ID used to retrieve it.',
		);
	}
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
