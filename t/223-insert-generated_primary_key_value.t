#!perl -T

use strict;
use warnings;

use lib 't';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 6	;
use Test::Type;


my $dbh = LocalTest::ok_database_handle();

ok(
	defined(
		my $id = time()
	),
	'Generated custom unique ID.',
);

ok(
	defined(
		my $object = DBIx::NinjaORM::Test->new()
	),
	'Create a new object.',
);

dies_ok(
	sub
	{
		my $row = $dbh->selectrow_hashref(
			q|
				SELECT created
				FROM tests
				WHERE test_id = ?
			|,
			{},
			$id,
		);
		
		die 'No row'
			if !defined( $row );
	},
	'No row with the custom ID.',
);

lives_ok(
	sub
	{
		$object->insert(
			{
				name  => 'test_pk_' . time(),
				value => 1,
			},
			generated_primary_key_value => $id,
		);
	},
	'Insert a test record with a custom ID.',
);

lives_ok(
	sub
	{
		my $row = $dbh->selectrow_hashref(
			q|
				SELECT created
				FROM tests
				WHERE test_id = ?
			|,
			{},
			$id,
		);
		
		die 'No row'
			if !defined( $row );
	},
	'There is now a row with that custom ID.',
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
	$info->{'default_dbh'} = LocalTest::get_database_handle();
	$info->{'table_name'} = 'tests';
	$info->{'primary_key_name'} = 'test_id';
	
	return $info;
}

1;
