#!perl -T

=head1 PURPOSE

Test removing rows via the objects.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Test::More tests => 7;
use Test::Type;


# Verify that the main class supports the method.
can_ok(
	'DBIx::NinjaORM',
	'remove',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'remove',
);

# Test that remove() requires a table name.
subtest(
	'The table name must be defined in static_class_info().',
	sub
	{
		ok(
			my $object = DBIx::NinjaORM::TestNoTableName->new(),
			'Create new object.',
		);
		
		throws_ok(
			sub
			{
				$object->remove();
			},
			qr/The table name for class 'DBIx::NinjaORM::TestNoTableName' is not defined/,
			'remove() fails.',
		);
	}
);

# Test that remove() requires a primary key name.
subtest(
	'The primary key name must be defined in static_class_info().',
	sub
	{
		ok(
			my $object = DBIx::NinjaORM::TestNoPK->new(),
			'Create new object.',
		);
		
		throws_ok(
			sub
			{
				$object->remove();
			},
			qr/Missing primary key name for class 'DBIx::NinjaORM::TestNoPK', cannot delete safely/,
			'Insert fails.',
		);
	}
);

# Test that remove() requires a primary key value.
subtest(
	'The primary key value must be defined.',
	sub
	{
		ok(
			defined(
				my $object = DBIx::NinjaORM::Test->new()
			),
			'Create new object.',
		);
		
		throws_ok(
			sub
			{
				$object->remove();
			},
			qr/The object of class 'DBIx::NinjaORM::Test' does not have a primary key value, cannot delete/,
			'remove() fails.',
		);
	}
);

# Insert a test object.
my $object;
subtest(
	'Insert test object.',
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
						name => 'test_remove_' . time(),
					}
				);
			},
			'Insert succeeds.',
		);
	}
);

# This object has a table name, primary key name and primary key value set
# properly. We should be able to delete it without issues.
lives_ok(
	sub
	{
		$object->remove();
	},
	'Remove object.',
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
