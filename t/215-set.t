#!perl -T

=head1 PURPOSE

Test setting fields and corresponding values with set().

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 7;


# Verify that the main class supports the method.
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

# Make sure that private fields cannot be set via set() by default.
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

# Make sure that private fields cannot be set via set() without 'force'.
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

# Make sure that private fields can be set via set() when the 'force' argument
# is specified and set to 1.
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


# Test subclass with private fields and a primary key name set.
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
