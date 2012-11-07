#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 5;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'static_class_info',
);

my $info;
lives_ok(
	sub
	{
		$info = DBIx::NinjaORM->static_class_info();
	},
	'Retrieve the static class info.',
);

ok_hashref(
	$info,
	name => 'Static class info',
);

my $mandatory_keys =
[
	qw(
		default_dbh
		memcache
		table_name
		primary_key_name
		list_cache_time
		object_cache_time
		unique_fields
		filtering_fields
		private_fields
		has_created_field
		has_modified_field
		cache_key_field
	)
];

subtest(
	'Verify the mandatory information.',
	sub
	{
		plan( tests => scalar( @$mandatory_keys ) );
		
		foreach my $key ( @$mandatory_keys )
		{
			ok(
				exists( $info->{ $key } ),
				"The mandatory key '$key' exists.",
			);
			delete( $info->{ $key } );
		}
	}
);

is(
	scalar( keys %$info ),
	0,
	'No unknown static class info keys found.',
);
