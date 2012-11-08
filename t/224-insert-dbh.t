#!perl -T

use strict;
use warnings;

use lib 't';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 4;
use Test::Type;


my $dbh = LocalTest::ok_database_handle();

ok(
	my $object = DBIx::NinjaORM::Test->new(),
	'Create new object.',
);

dies_ok(
	sub
	{
		$object->insert(
			{
				name => 'test_insert_' . time(),
			}
		)
	},
	'Insert on the default dbh fails.',
);

lives_ok(
	sub
	{
		$object->insert(
			{
				name => 'test_insert_' . time(),
			},
			dbh => $dbh,
		)
	},
	'Insert with a custom dbh succeeds.',
);


package DBIx::NinjaORM::Test;

use strict;
use warnings;

use lib 't';
use LocalTest;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	my ( $class ) = @_;
	
	my $info = $class->SUPER::static_class_info();
	$info->{'default_dbh'} = 'invalid';
	$info->{'table_name'} = 'tests';
	$info->{'primary_key_name'} = 'test_id';
	
	return $info;
}

1;
