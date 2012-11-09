#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 6;
use Test::Type;


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
				)
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
					field => 'value',
				)
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
					field => 'value',
				)
			},
			'Insert fails.',
		);
	}
);

subtest(
	'Insert with correct information.',
	sub
	{
		ok(
			my $object = DBIx::NinjaORM::Test->new(),
			'Create new object.',
		);
		
		lives_ok(
			sub
			{
				$object->insert(
					{
						name => 'test_insert_' . time(),
					}
				)
			},
			'Insert succeeds.',
		);
	}
);


package DBIx::NinjaORM::Test;

use strict;
use warnings;

use lib 't';
use LocalTest;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'default_dbh'      => LocalTest::get_database_handle(),
		'table_name'       => 'tests',
		'primary_key_name' => 'test_id',
	};
}

1;


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
