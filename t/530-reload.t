#!perl -T

=head1 PURPOSE

Test the reload() method.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 8;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'reload',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'reload',
);

# Insert an object we'll use for tests here.
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
				name => 'test_reload_' . time(),
			}
		)
	},
	'Insert succeeds.',
);

# Set a test field which should go away upon reload.
ok(
	$object->{'_test_key'} = 1,
	'Set a flag on the object that should not be there anymore after we reload the object.',
);

# Reload an object that wasn't retrieved from the database.
my $original_object_location = $object;
lives_ok(
	sub
	{
		$object->reload();
	},
	'Reload the object.',
);
is(
	$object,
	$original_object_location,
	'The object location in memory has not changed.',
);

# If the object has been reloaded properly, the test flag shouldn't be there
# anymore.
is(
	$object->{'_test_key'},
	undef,
	'The object was reloaded (the test property is gone)'
);


# Test subclass with enough information to insert rows.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use lib 't';
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

