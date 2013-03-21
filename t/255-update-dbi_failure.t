#!perl -T

=head1 PURPOSE

Test that errors thrown by DBI when trying to update a row via
DBIx::NinjaORM->update() are caught and propagated properly.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 3;
use Test::NoWarnings;
use Test::Type;


# Insert a test object.
my $object;
subtest(
	'Create test object and insert the corresponding test row.',
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
						name => 'test_update_failure_' . time(),
					},
				);
			},
			'Insert succeeds.',
		);
	}
);

# Re-bless the database connection as a DBI::db::Test object, which is the
# same as DBI::db except that it overrides prepare() to make it die.
my $dbh = $object->get_default_dbh();
bless( $dbh, 'DBI::db::Test' );

throws_ok(
	sub
	{
		$object->update(
			{
				name => 'test_update_failure_' . time(),
			}
		);
	},
	qr/\A\QUpdate failed: died in prepare()\E/,
	'Caught update failure.',
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


# Subclass DBI::db and override prepare() to make it die.
# This is what allows testing that errors thrown by DBI are properly handled
# by DBIx::NinjaORM.
package DBI::db::Test;

use base 'DBI::db';

sub prepare
{
	die 'died in prepare()';
}

1;
