#!perl -T

use strict;
use warnings;

use lib 't';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More;


LocalTest::ok_memcache();

plan( tests => 3 );

subtest(
	'Test with skip_cache=undef.',
	sub
	{
		plan( tests => 11 );
		
		ok(
			defined(
				my $insert_test = DBIx::NinjaORM::Test->new()
			),
			'Create DBIx::NinjaORM::Test object.',
		);
		
		ok(
			$insert_test->insert(
				{
					name => 'skip_cache_1_' . time(),
				}
			),
			'Insert new row.',
		);
		
		isnt(
			$insert_test->id(),
			undef,
			'The inserted row has a valid ID.',
		);
		
		ok(
			my $tests1 = DBIx::NinjaORM::Test->retrieve_list(
				id         => $insert_test->id(),
				skip_cache => undef,
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
		);
		
		is(
			$test1->{'_debug'}->{'object_cache_used'},
			0,
			'The object cache is not used.',
		);
		
		ok(
			my $tests2 = DBIx::NinjaORM::Test->retrieve_list(
				id         => $insert_test->id(),
				skip_cache => undef,
			),
			'Retrieve rows by ID.',
		);
		
		is(
			scalar( @$tests2 ),
			1,
			'Found one row.',
		);
		
		my $test2 = $tests2->[0];
		
		is(
			$test2->{'_debug'}->{'list_cache_used'},
			0,
			'The list cache is not used.',
		) || diag( explain( $test2->{'_debug'} ) );
		
		is(
			$test2->{'_debug'}->{'object_cache_used'},
			1,
			'The object cache is used.',
		) || diag( explain( $test2->{'_debug'} ) );
	}
);

subtest(
	'Test with skip_cache=0.',
	sub
	{
		plan( tests => 11 );
		
		ok(
			defined(
				my $insert_test = DBIx::NinjaORM::Test->new()
			),
			'Create DBIx::NinjaORM::Test object.',
		);
		
		ok(
			$insert_test->insert(
				{
					name => 'skip_cache_2_' . time(),
				}
			),
			'Insert new row.',
		);
		
		isnt(
			$insert_test->id(),
			undef,
			'The inserted row has a valid ID.',
		);
		
		ok(
			my $tests1 = DBIx::NinjaORM::Test->retrieve_list(
				id         => $insert_test->id(),
				skip_cache => 0,
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
		);
		
		is(
			$test1->{'_debug'}->{'object_cache_used'},
			0,
			'The object cache is used.',
		);
		
		ok(
			my $tests2 = DBIx::NinjaORM::Test->retrieve_list(
				id         => $insert_test->id(),
				skip_cache => 0,
			),
			'Retrieve rows by ID.',
		);
		
		is(
			scalar( @$tests2 ),
			1,
			'Found one row.',
		);
		
		my $test2 = $tests2->[0];
		
		is(
			$test2->{'_debug'}->{'list_cache_used'},
			0,
			'The list cache is not used.',
		);
		
		is(
			$test2->{'_debug'}->{'object_cache_used'},
			1,
			'The object cache is used.',
		);
	}
);

subtest(
	'Test with skip_cache=1.',
	sub
	{
		plan( tests => 11 );
		
		ok(
			defined(
				my $insert_test = DBIx::NinjaORM::Test->new()
			),
			'Create DBIx::NinjaORM::Test object.',
		);
		
		ok(
			$insert_test->insert(
				{
					name => 'skip_cache_3_' . time(),
				}
			),
			'Insert new row.',
		);
		
		isnt(
			$insert_test->id(),
			undef,
			'The inserted row has a valid ID.',
		);
		
		ok(
			my $tests1 = DBIx::NinjaORM::Test->retrieve_list(
				id         => $insert_test->id(),
				skip_cache => 1,
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
		);
		
		is(
			$test1->{'_debug'}->{'object_cache_used'},
			0,
			'The object cache is not used.',
		);
		
		ok(
			my $tests2 = DBIx::NinjaORM::Test->retrieve_list(
				id         => $insert_test->id(),
				skip_cache => 1,
			),
			'Retrieve rows by ID.',
		);
		
		is(
			scalar( @$tests2 ),
			1,
			'Found one row.',
		);
		
		my $test2 = $tests2->[0];
		
		is(
			$test2->{'_debug'}->{'list_cache_used'},
			0,
			'The list cache is not used.',
		);
		
		is(
			$test2->{'_debug'}->{'object_cache_used'},
			0,
			'The object cache is not used.',
		);
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
	$info->{'object_cache_time'} = 3;
	$info->{'list_cache_time'} = 3;
	$info->{'memcache'} = LocalTest::get_memcache();
	
	return $info;
}

1;
