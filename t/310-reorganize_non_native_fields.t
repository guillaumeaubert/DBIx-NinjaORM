#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 7;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'reorganize_non_native_fields',
);

can_ok(
	'DBIx::NinjaORM::Test',
	'reorganize_non_native_fields',
);

ok(
	defined(
		my $test = DBIx::NinjaORM::Test->new()
	),
	'Create a new Test object.',
);

note( 'Set up fields inside the object' );
$test->{'_account_account_id'} = 1;
$test->{'_table_field'} = 'value';
$test->{'name'} = 'Guillaume';
diag( explain( $test ) );

lives_ok(
	sub
	{
		$test->reorganize_non_native_fields();
	},
	'Reorganize non-native fields in the object.',
);

subtest(
	'Joined field.',
	sub
	{
		plan( tests => 3 );
		
		ok(
			exists(
				$test->{'_table'}->{'field'}
			),
			'"_table->field" exists.',
		);
		
		is(
			$test->{'_table'}->{'field'},
			'value',
			'The value matches.',
		);
		
		ok(
			!exists(
				$test->{'_table_field'}
			),
			'"_table_field" does not exist anymore.',
		);
	}
);

subtest(
	'Joined field with an underscore in the field name.',
	sub
	{
		plan( tests => 3 );
		
		ok(
			exists(
				$test->{'_account'}->{'account_id'}
			),
			'"_account->account_id" exists.',
		);
		
		is(
			$test->{'_account'}->{'account_id'},
			1,
			'The value matches.',
		);
		
		ok(
			!exists(
				$test->{'_account_account_id'}
			),
			'"_account_account_id" does not exist anymore.',
		);
	}
);

is(
	$test->{'name'},
	'Guillaume',
	'Fields not starting with an underscore have been left intact.',
);


package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';

1;

