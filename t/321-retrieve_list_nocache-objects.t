#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 6;
use Test::Type;


my $test_name = 'test_nocache_' . time() . '_';

foreach my $count ( 1..3 )
{
	subtest(
		"Insert test object $count.",
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
							name => $test_name . $count,
						}
					);
				},
				'Insert succeeds.',
			);
		}
	);
}

my $objects;
lives_ok(
	sub
	{
		$objects = DBIx::NinjaORM::Test->retrieve_list_nocache(
			name => [ map { $test_name . $_ } ( 1..3 ) ],
		);
	},
	'Retrieve the objects matching the names.',
);

is(
	scalar( @$objects ),
	3,
	'Retrieved three objects.',
) || diag( explain( $objects ) );

subtest(
	'Verify class of objects.',
	sub
	{
		plan( tests => 3 );
		
		foreach my $object ( @$objects )
		{
			isa_ok(
				$object,
				'DBIx::NinjaORM::Test',
			);
		}
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
	my ( $class ) = @_;
	
	my $info = $class->SUPER::static_class_info();
	
	$info->{'default_dbh'} = LocalTest::get_database_handle();
	$info->{'table_name'} = 'tests';
	$info->{'primary_key_name'} = 'test_id';
	$info->{'filtering_fields'} = [ 'name' ];
	
	return $info;
}

1;
