#!perl -T

use strict;
use warnings;

use lib 't';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 5;


my $dbh = LocalTest::ok_database_handle();

my $quoted_field = $dbh->quote_identifier( 'test_field' );

my $tests = 
[
	# Operator "between".
	{
		name     => 'Test operator="between" with correct input.',
		input    =>
		{
			field    => 'test_field',
			operator => 'between',
			values   => [ 1, 2 ],
		},
		expected =>
		{
			clause => "$quoted_field BETWEEN ? AND ?",
			values => [ 1, 2 ],
		},
	},
	{
		name     => 'Test operator="between" with incorrect values.',
		input    =>
		{
			field    => 'test_field',
			operator => 'between',
			values   => 3,
		},
		expected => undef,
	},
	# Operator "NULL".
	{
		name     => 'Test operator="NULL" with correct input.',
		input    =>
		{
			field    => 'test_field',
			operator => 'NULL',
			values   => [],
		},
		expected =>
		{
			clause => "$quoted_field IS NULL",
			values => [],
		},
	},
	{
		name     => 'Test operator="NULL" with values that should be ignored.',
		input    =>
		{
			field    => 'test_field',
			operator => 'NULL',
			values   => [ 1, 2, 3 ],
		},
		expected =>
		{
			clause => "$quoted_field IS NULL",
			values => [],
		},
	},
	# Operator "=".
	{
		name     => 'Test operator="=" with values=scalar.',
		input    =>
		{
			field    => 'test_field',
			operator => '=',
			values   => 'test_value',
		},
		expected =>
		{
			clause => "$quoted_field = ?",
			values => [ 'test_value' ],
		},
	},
	{
		name     => 'Test operator="=" with values=arrayref.',
		input    =>
		{
			field    => 'test_field',
			operator => '=',
			values   => [ 1, 'a' ],
		},
		expected =>
		{
			clause => "$quoted_field IN (?, ?)",
			values => [ 1, 'a' ],
		},
	},
	# Operator "not".
	{
		name     => 'Test operator="not" with values=scalar.',
		input    =>
		{
			field    => 'test_field',
			operator => 'not',
			values   => 'test_value',
		},
		expected =>
		{
			clause => "$quoted_field != ?",
			values => [ 'test_value' ],
		},
	},
	{
		name     => 'Test operator="not" with values=arrayref.',
		input    =>
		{
			field    => 'test_field',
			operator => 'not',
			values   => [ 1, 'a' ],
		},
		expected =>
		{
			clause => "$quoted_field NOT IN (?, ?)",
			values => [ 1, 'a' ],
		},
	},
	# Operator ">".
	{
		name     => 'Test operator=">" with values=scalar.',
		input    =>
		{
			field    => 'test_field',
			operator => '>',
			values   => 4,
		},
		expected =>
		{
			clause => "$quoted_field > ?",
			values => [ 4 ],
		},
	},
	{
		name     => 'Test operator=">" with values=arrayref.',
		input    =>
		{
			field    => 'test_field',
			operator => '>',
			values   => [ 1, 3 ],
		},
		expected =>
		{
			clause => "$quoted_field > ?",
			values => [ 3 ],
		},
	},
	# Operator ">=".
	{
		name     => 'Test operator=">" with values=scalar.',
		input    =>
		{
			field    => 'test_field',
			operator => '>=',
			values   => 4,
		},
		expected =>
		{
			clause => "$quoted_field >= ?",
			values => [ 4 ],
		},
	},
	{
		name     => 'Test operator=">=" with values=arrayref.',
		input    =>
		{
			field    => 'test_field',
			operator => '>=',
			values   => [ 1, 3 ],
		},
		expected =>
		{
			clause => "$quoted_field >= ?",
			values => [ 3 ],
		},
	},
	# Operator "<".
	{
		name     => 'Test operator="<" with values=scalar.',
		input    =>
		{
			field    => 'test_field',
			operator => '<',
			values   => 4,
		},
		expected =>
		{
			clause => "$quoted_field < ?",
			values => [ 4 ],
		},
	},
	{
		name     => 'Test operator="<" with values=arrayref.',
		input    =>
		{
			field    => 'test_field',
			operator => '<',
			values   => [ 1, 3 ],
		},
		expected =>
		{
			clause => "$quoted_field < ?",
			values => [ 1 ],
		},
	},
	# Operator "<=".
	{
		name     => 'Test operator="<=" with values=scalar.',
		input    =>
		{
			field    => 'test_field',
			operator => '<=',
			values   => 4,
		},
		expected =>
		{
			clause => "$quoted_field <= ?",
			values => [ 4 ],
		},
	},
	{
		name     => 'Test operator="<=" with values=arrayref.',
		input    =>
		{
			field    => 'test_field',
			operator => '<=',
			values   => [ 1, 3 ],
		},
		expected =>
		{
			clause => "$quoted_field <= ?",
			values => [ 1 ],
		},
	},
];

can_ok(
	'DBIx::NinjaORM',
	'build_filtering_clause',
);

foreach my $test ( @$tests )
{
	my $input = $test->{'input'};
	my $expected = $test->{'expected'};
	
	if ( defined( $expected ) )
	{
		subtest(
			$test->{'name'},
			sub
			{
				plan( tests => 3 );
				
				my ( $clause, $values );
				lives_ok(
					sub
					{
						( $clause, $values ) = DBIx::NinjaORM::Test->build_filtering_clause(
							%$input
						);
					},
					'Create the filtering clause.',
				);
				
				is(
					$clause,
					$expected->{'clause'},
					'The clause matches.',
				);
				
				is_deeply(
					$values,
					$expected->{'values'},
					'The values match.',
				) || diag( explain( 'Retrieved: ', $values, 'Expected: ', $expected->{'values'} ) );
			}
		);
	}
	else
	{
		dies_ok(
			sub
			{
				DBIx::NinjaORM::Test->build_filtering_clause(
					%$input
				);
			},
			$test->{'name'},
		);
	}
}


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
		'default_dbh' => LocalTest::get_database_handle(),
	};
}

1;
