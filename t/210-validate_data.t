#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 7;


can_ok(
	'DBIx::NinjaORM',
	'validate_data',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'validate_data',
);

ok(
	my $object = DBIx::NinjaORM::Test->new(),
	'Create new object.',
);

subtest(
	'Set primary key value.',
	sub
	{
		plan( tests => 2 );
		
		my $validated_data;
		lives_ok(
			sub
			{
				$validated_data = $object->validate_data(
					{
						test_pk => 1,
					}
				);
			},
			'Validate data.',
		);
		
		my $expected = 
		{
			test_pk => 1,
		};
		
		is_deeply(
			$validated_data,
			$expected,
			'Setting the primary key on an object without one is valid.',
		) || diag( explain( 'Retrieved: ', $validated_data, 'Expected: ', $expected ) );
	}                 
);

subtest(
	'Fail to override primary key value.',
	sub
	{
		plan( tests => 2 );
		
		ok(
			$object->{'test_pk'} = 2,
			'Set primary key value internally.',
		);
		
		my $validated_data;
		dies_ok(
			sub
			{
				$validated_data = $object->validate_data(
					{
						test_pk => 1,
					}
				);
			},
			'Validate data.',
		);
	}
);

subtest(
	'Fields starting with an underscore are ignored.',
	sub
	{
		plan( tests => 2 );
		
		my $validated_data;
		lives_ok(
			sub
			{
				$validated_data = $object->validate_data(
					{
						'field1' => 'value1',
						'_field' => 'value2',
					}
				);
			},
			'Validate data.',
		);
		
		my $expected = 
		{
			field1 => 'value1',
		};
		
		is_deeply(
			$validated_data,
			$expected,
			'The field with a leading underscore got dropped.',
		) || diag( explain( 'Retrieved: ', $validated_data, 'Expected: ', $expected ) );
	}
);

subtest(
	'Private fields are ignored.',
	sub
	{
		plan( tests => 2 );
		
		my $validated_data;
		lives_ok(
			sub
			{
				$validated_data = $object->validate_data(
					{
						'field1'        => 'value1',
						'private_field' => 'value2',
					}
				);
			},
			'Validate data.',
		);
		
		my $expected = 
		{
			field1 => 'value1',
		};
		
		is_deeply(
			$validated_data,
			$expected,
			'The private field got dropped.',
		) || diag( explain( 'Retrieved: ', $validated_data, 'Expected: ', $expected ) );
	}
);


package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		'private_fields'   => [ 'private_field' ],
		'primary_key_name' => 'test_pk',
	};
}

1;
