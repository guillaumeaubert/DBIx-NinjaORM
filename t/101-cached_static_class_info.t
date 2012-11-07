#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Deep;
use Test::Exception;
use Test::More tests => 4;
use Test::Type;


can_ok(
	'DBIx::NinjaORM',
	'cached_static_class_info',
);

my $info;
lives_ok(
	sub
	{
		$info = DBIx::NinjaORM->static_class_info();
	},
	'Retrieve the static class info.',
);

my $cached_info;
lives_ok(
	sub
	{
		$cached_info = DBIx::NinjaORM->cached_static_class_info();
	},
	'Retrieve the cached static class info.',
);

cmp_deeply(
	$cached_info,
	$info,
	'Cached info matches info.',
);
