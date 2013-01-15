#!perl -T

=head1 PURPOSE

Test inserting rows via the objects.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 9;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'insert',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'insert',
);

subtest(
	'The first argument must be a hashref.',
	sub
	{
		ok(
			my $object = DBIx::NinjaORM::Test->new(),
			'Create new object.',
		);
		
		dies_ok(
			sub
			{
				$object->insert(
					field => 'value',
				);
			},
			'The first argument must be a hashref.',
		);
	}
);

subtest(
	'The table name must be defined in static_class_info().',
	sub
	{
		ok(
			my $object = DBIx::NinjaORM::TestNoTableName->new(),
			'Create new object.',
		);
		
		dies_ok(
			sub
			{
				$object->insert(
					{
						field => 'value',
					}
				);
			},
			'Insert fails.',
		);
	}
);

subtest(
	'The primary key name must be defined in static_class_info().',
	sub
	{
		ok(
			my $object = DBIx::NinjaORM::TestNoPK->new(),
			'Create new object.',
		);
		
		dies_ok(
			sub
			{
				$object->insert(
					{
						field => 'value',
					}
				);
			},
			'Insert fails.',
		);
	}
);

my $object;
subtest(
	'Insert with correct information.',
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
						name => 'test_insert_' . time(),
					}
				);
			},
			'Insert succeeds.',
		);
	}
);

ok(
	$object->{'created'} > 0,
	"The 'created' field was auto-populated.",
) || diag( explain( $object ) );

ok(
	$object->{'modified'} > 0,
	"The 'modified' field was auto-populated.",
) || diag( explain( $object ) );

isnt(
	$object->id(),
	undef,
	'The auto-increment field was populated.',
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


# Test subclass without a table name defined, which should not allow inserting
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
# inserting rows.
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
