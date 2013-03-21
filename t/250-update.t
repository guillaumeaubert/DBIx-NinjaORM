#!perl -T

=head1 PURPOSE

Test the C<update()> method on C<DBIx::NinjaORM> objects.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 10;
use Test::NoWarnings;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'update',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'update',
);

# We set the creation time for the test record 10 seconds in the past to be
# able to make sure that calls to update() leave the 'created' field
# unaffected.
my $created_time = time() - 10;
				
# Insert a test object.
my $object;
subtest(
	'Create test object and insert the corresponding test row.',
	sub
	{
		ok(
			$object = DBIx::NinjaORM::Test->new(),
			'Create new object.',
		);
		
		lives_ok(
			sub
			{
				$object->insert(
					{
						name => 'test_update_' . $created_time,
					},
					overwrite_created => $created_time,
				);
			},
			'Insert succeeds.',
		);
	}
);

subtest(
	'The first argument must be a hashref.',
	sub
	{
		plan( tests => 2 );
		
		# Copy the test object, to leave the original intact and prevent
		# bleeding between tests.
		ok(
			defined(
				my $object_copy = Storable::dclone( $object )
			),
			'Copy the test object.',
		);
		
		dies_ok(
			sub
			{
				$object_copy->update(
					name => 'value',
				);
			},
			'Update fails.',
		);
	}
);

subtest(
	'The table name must be defined in static_class_info().',
	sub
	{
		plan( tests => 3 );
		
		# Copy the test object, to leave the original intact and prevent
		# bleeding between tests.
		ok(
			defined(
				my $object_copy = Storable::dclone( $object )
			),
			'Copy the test object.',
		);
		
		# Re-bless the object with the class that has no table name
		# defined.
		ok(
			bless(
				$object_copy,
				'DBIx::NinjaORM::TestNoTableName',
			),
			'Re-bless the object with a class that has no table name defined.',
		);
		
		dies_ok(
			sub
			{
				$object_copy->update(
					{
						name => 'value',
					}
				)
			},
			'Update fails.',
		);
	}
);

subtest(
	'The primary key name must be defined in static_class_info().',
	sub
	{
		plan( tests => 3 );
		
		# Copy the test object, to leave the original intact and prevent
		# bleeding between tests.
		ok(
			defined(
				my $object_copy = Storable::dclone( $object )
			),
			'Copy the test object.',
		);
		
		# Re-bless the object with the class that has no primary key
		# name defined.
		ok(
			bless(
				$object_copy,
				'DBIx::NinjaORM::TestNoPK',
			),
			'Re-bless the object with a class that has no primary key name defined.',
		);
		
		dies_ok(
			sub
			{
				$object_copy->update(
					{
						name => 'value',
					}
				);
			},
			'Update fails.',
		);
	}
);

lives_ok(
	sub
	{
		$object->update(
			{
				name => 'test_update_' . time(),
			}
		);
	},
	'Update succeeds',
);

is(
	$object->{'created'},
	$created_time,
	"The 'created' field was not affected.",
) || diag( explain( $object ) );

ok(
	( time() - $object->{'modified'} ) < 2,
	"The 'modified' field was set in the last two seconds.",
) || diag( explain( $object ) );


# Test subclass with enough information to update rows.
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


# Test subclass without a table name defined, which should not allow updating
# rows.
package DBIx::NinjaORM::TestNoTableName;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'primary_key_name' => 'test_id',
	};
}

1;


# Test subclass without a primary key name defined, which should not allow
# updating rows.
package DBIx::NinjaORM::TestNoPK;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'table_name'       => 'tests',
	};
}

1;
