#!perl -T

=head1 PURPOSE

Test inserting rows when the table doesn't have a 'modified' field.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Test::More tests => 4;
use Test::Type;


ok(
	my $object = DBIx::NinjaORM::Test->new(),
	'Create new object.',
);

my $name = 'test_insert_nomodified_' . time();
lives_ok(
	sub
	{
		$object->insert(
			{
				name => $name,
			}
		)
	},
	'Insert succeeds.',
);

my $row;
lives_ok(
	sub
	{
		my $dbh = $object->assert_dbh();
		
		$row = $dbh->selectrow_hashref(
			q|
				SELECT *
				FROM no_modified_tests
				WHERE name = ?
			|,
			{},
			$name,
		);
		
		die 'No row'
			if !defined( $row );
	},
	'Retrieve the inserted row',
);

ok(
	!exists( $row->{'modified'} ),
	'The row does not have a modified field.',
) || diag( explain( $row ) );


# Test subclass with enough information to successfully insert rows, and
# 'has_modified_field' set to 0.
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
	
	$info->set(
		{
			'default_dbh'        => LocalTest::get_database_handle(),
			'table_name'         => 'no_modified_tests',
			'primary_key_name'   => 'test_id',
			'has_modified_field' => 0,
		}
	);
	
	return $info;
}

1;

