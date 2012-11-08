#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 7;


can_ok(
	'DBIx::NinjaORM',
	'set',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'set',
);

ok(
	my $object = DBIx::NinjaORM::Test->new(),
	'Create new object.',
);

dies_ok(
	sub
	{
		$object->set(
			field => 'value',
		)
	},
	'The first argument must be a hashref.',
);

subtest(
	'Set a private field without the "force" argument.',
	sub
	{
		plan( tests => 3 );
		
		ok(
			!exists( $object->{'private_field'} ),
			'"private_field" does not exist on the object.',
		);
		
		lives_ok(
			sub
			{
				$object->set(
					{
						private_field => 'value',
					}
				);
			},
			'Set value.',
		);
		
		ok(
			!exists( $object->{'private_field'} ),
			'"private_field" does not exist on the object.',
		);
	}
);

subtest(
	'Set a private field with force=0.',
	sub
	{
		plan( tests => 3 );
		
		ok(
			!exists( $object->{'private_field'} ),
			'"private_field" does not exist on the object.',
		);
		
		lives_ok(
			sub
			{
				$object->set(
					{
						private_field => 'value',
					},
					force => 0,
				);
			},
			'Set value.',
		);
		
		ok(
			!exists( $object->{'private_field'} ),
			'"private_field" does not exist on the object.',
		);
	}
);

subtest(
	'Set a private field with force=1.',
	sub
	{
		plan( tests => 3 );
		
		ok(
			!exists( $object->{'private_field'} ),
			'"private_field" does not exist on the object.',
		);
		
		lives_ok(
			sub
			{
				$object->set(
					{
						private_field => 'value',
					},
					force => 1,
				);
			},
			'Set value.',
		);
		
		is(
			$object->{'private_field'},
			'value',
			'The private field is set.',
		);
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
