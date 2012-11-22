#!perl -T

=head1 PURPOSE

Test the dump() method.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 6;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'dump',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'dump',
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
						name => 'test_dump_' . time(),
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

# Dump the object.
my $output;
lives_ok(
	sub
	{
		$output = $object->dump();
	},
	'Dump the object.',
);

# Make sure the output isn't empty.
like(
	$output,
	qr/account_id/,
	"The output includes the object's account ID.",
) || diag( $output );


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

