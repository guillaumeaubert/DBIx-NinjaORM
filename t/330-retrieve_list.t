#!perl -T

use strict;
use warnings;

use lib 't';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 7;


can_ok(
	'DBIx::NinjaORM',
	'retrieve_list',
);

can_ok(
	'DBIx::NinjaORM::ListCache',
	'retrieve_list',
);

can_ok(
	'DBIx::NinjaORM::ObjectCache',
	'retrieve_list',
);

can_ok(
	'DBIx::NinjaORM::NoCache',
	'retrieve_list',
);

subtest(
	'Test retrieve_list() with a class that has no cache time.',
	sub
	{
		plan( tests => 5 );
		
		is(
			DBIx::NinjaORM::NoCache->get_object_cache_time(),
			undef,
			'The object cache time for the class is undef.',
		);

		is(
			DBIx::NinjaORM::NoCache->get_list_cache_time(),
			undef,
			'The list cache time for the class is undef.',
		);
		
		is(
			DBIx::NinjaORM::NoCache->retrieve_list(),
			'retrieve_list_nocache',
			'Calling retrieve_list() with no arguments falls back to the non-cached version.',
		);
		
		is(
			DBIx::NinjaORM::NoCache->retrieve_list(
				skip_cache => 0,
			),
			'retrieve_list_nocache',
			'Calling retrieve_list() with skip_cache=0 uses the non-cached version.',
		);
		
		is(
			DBIx::NinjaORM::NoCache->retrieve_list(
				skip_cache => 1,
			),
			'retrieve_list_nocache',
			'Calling retrieve_list() with skip_cache=1 uses the non-cached version.',
		);
	}
);

subtest(
	'Test retrieve_list() with a class that has object_cache_time=3.',
	sub
	{
		plan( tests => 5 );
		
		is(
			DBIx::NinjaORM::ObjectCache->get_object_cache_time(),
			3,
			'The object cache time for the class is properly set.',
		);

		is(
			DBIx::NinjaORM::ObjectCache->get_list_cache_time(),
			undef,
			'The list cache time for the class is properly set.',
		);
		
		is(
			DBIx::NinjaORM::ObjectCache->retrieve_list(),
			'retrieve_list_cache',
			'Calling retrieve_list() with no arguments falls back to the cached version.',
		);
		
		is(
			DBIx::NinjaORM::ObjectCache->retrieve_list(
				skip_cache => 0,
			),
			'retrieve_list_cache',
			'Calling retrieve_list() with skip_cache=0 uses the cached version.',
		);
		
		is(
			DBIx::NinjaORM::ObjectCache->retrieve_list(
				skip_cache => 1,
			),
			'retrieve_list_nocache',
			'Calling retrieve_list() with skip_cache=1 uses the non-cached version.',
		);
	}
);

subtest(
	'Test retrieve_list() with a class that has list_cache_time=3.',
	sub
	{
		plan( tests => 5 );
		
		is(
			DBIx::NinjaORM::ListCache->get_object_cache_time(),
			undef,
			'The object cache time for the class is properly set.',
		);

		is(
			DBIx::NinjaORM::ListCache->get_list_cache_time(),
			3,
			'The list cache time for the class is properly set.',
		);
		
		is(
			DBIx::NinjaORM::ListCache->retrieve_list(),
			'retrieve_list_cache',
			'Calling retrieve_list() with no arguments falls back to the cached version.',
		);
		
		is(
			DBIx::NinjaORM::ListCache->retrieve_list(
				skip_cache => 0,
			),
			'retrieve_list_cache',
			'Calling retrieve_list() with skip_cache=0 uses the cached version.',
		);
		
		is(
			DBIx::NinjaORM::ListCache->retrieve_list(
				skip_cache => 1,
			),
			'retrieve_list_nocache',
			'Calling retrieve_list() with skip_cache=1 uses the non-cached version.',
		);
	}
);


package DBIx::NinjaORM::ListCache;

use strict;
use warnings;

use base 'DBIx::NinjaORM';

sub static_class_info
{
	my ( $class ) = @_;
	my $static_class_info = $class->SUPER::static_class_info();
	
	$static_class_info->{'object_cache_time'} = undef;
	$static_class_info->{'list_cache_time'} = 3;
	
	return $static_class_info;
}

sub retrieve_list_cache
{
	return 'retrieve_list_cache';
}

sub retrieve_list_nocache
{
	return 'retrieve_list_nocache';
}

1;


package DBIx::NinjaORM::ObjectCache;

use strict;
use warnings;

use base 'DBIx::NinjaORM';

sub static_class_info
{
	my ( $class ) = @_;
	my $static_class_info = $class->SUPER::static_class_info();
	
	$static_class_info->{'object_cache_time'} = 3;
	$static_class_info->{'list_cache_time'} = undef;
	
	return $static_class_info;
}

sub retrieve_list_cache
{
	return 'retrieve_list_cache';
}

sub retrieve_list_nocache
{
	return 'retrieve_list_nocache';
}

1;


package DBIx::NinjaORM::NoCache;

use strict;
use warnings;

use base 'DBIx::NinjaORM';

sub static_class_info
{
	my ( $class ) = @_;
	my $static_class_info = $class->SUPER::static_class_info();
	
	$static_class_info->{'object_cache_time'} = undef;
	$static_class_info->{'list_cache_time'} = undef;
	
	return $static_class_info;
}

sub retrieve_list_cache
{
	return 'retrieve_list_cache';
}

sub retrieve_list_nocache
{
	return 'retrieve_list_nocache';
}

1;
