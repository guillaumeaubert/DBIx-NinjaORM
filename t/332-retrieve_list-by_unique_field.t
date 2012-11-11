#!perl -T

use strict;
use warnings;

use lib 't';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More;


LocalTest::ok_memcache();

my $tests =
[
	{
		skip_cache           => undef,
		second_retrieve_list =>
		{
			list_cache_used   => 0,
			object_cache_used => 1,
		},
	},
	{
		skip_cache           => 0,
		second_retrieve_list =>
		{
			list_cache_used   => 0,
			object_cache_used => 1,
		},
	},
	{
		skip_cache           => 1,
		second_retrieve_list =>
		{
			list_cache_used   => 0,
			object_cache_used => 0,
		},
	},
];

plan( tests => scalar( @$tests ) );

my $count = 0;
foreach my $test ( @$tests )
{
	$count++;
	my $skip_cache = $test->{'skip_cache'};
	
	subtest(
		'Test with skip_cache=' . ( $skip_cache // 'undef' ). '.',
		sub
		{
			plan( tests => 10 );
			
			ok(
				defined(
					my $insert_test = DBIx::NinjaORM::Test->new()
				),
				'Create DBIx::NinjaORM::Test object.',
			);
			
			my $name = 'by_unique_field_' . $count . '_' . time();
			ok(
				$insert_test->insert(
					{
						name => $name,
					}
				),
				'Insert new row.',
			);
			
			ok(
				my $tests1 = DBIx::NinjaORM::Test->retrieve_list(
					name       => $name,
					skip_cache => $skip_cache,
				),
				'Retrieve rows by ID.',
			);
			
			is(
				scalar( @$tests1 ),
				1,
				'Found one row.',
			);
			
			my $test1 = $tests1->[0];
			
			is(
				$test1->{'_debug'}->{'list_cache_used'},
				0,
				'The list cache is not used.',
			) || diag( explain( $test1->{'_debug'} ) );
			
			is(
				$test1->{'_debug'}->{'object_cache_used'},
				0,
				'The object cache is not used.',
			) || diag( explain( $test1->{'_debug'} ) );
			
			ok(
				my $tests2 = DBIx::NinjaORM::Test->retrieve_list(
					name       => $name,
					skip_cache => $skip_cache,
				),
				'Retrieve rows by ID.',
			);
			
			is(
				scalar( @$tests2 ),
				1,
				'Found one row.',
			);
			
			my $test2 = $tests2->[0];
			
			my $expected_list_cache = $test->{'second_retrieve_list'}->{'list_cache_used'};
			is(
				$test2->{'_debug'}->{'list_cache_used'},
				$expected_list_cache,
				'The list cache is ' . ( $expected_list_cache ? 'used' : 'not used' ) . '.',
			) || diag( explain( $test2->{'_debug'} ) );
			
			my $expected_object_cache = $test->{'second_retrieve_list'}->{'object_cache_used'};
			is(
				$test2->{'_debug'}->{'object_cache_used'},
				$expected_object_cache,
				'The object cache is ' . ( $expected_object_cache ? 'used' : 'not used' ) . '.',
			) || diag( explain( $test2->{'_debug'} ) );
		}
	);
}


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
	$info->{'unique_fields'} = [ 'name' ];
	$info->{'object_cache_time'} = 3;
	$info->{'list_cache_time'} = 3;
	$info->{'memcache'} = LocalTest::get_memcache();
	
	return $info;
}

1;
