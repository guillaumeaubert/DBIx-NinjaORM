#!perl -T

=head1 PURPOSE

Test retrieving data from the memcache cache.

=cut

use strict;
use warnings;

use lib 't/lib';
use LocalTest;

use DBIx::NinjaORM;
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Test::More;


LocalTest::ok_memcache();

plan( tests => 6 );

dies_ok(
	sub
	{
		DBIx::NinjaORM::Test->get_cache();
	},
	'The "key" argument cannot be undefined.'
);

dies_ok(
	sub
	{
		DBIx::NinjaORM::Test->get_cache( key => '' );
	},
	'The "key" argument cannot be empty.'
);

dies_ok(
	sub
	{
		DBIx::NinjaORM::Test->get_cache( invalid_argument => 1 );
	},
	'Invalid argument names are detected properly.'
);

my $test_value = time();
lives_ok(
	sub
	{
		DBIx::NinjaORM::Test->set_cache(
			key         => 'test_get_cache',
			value       => $test_value,
			expire_time => time() + 100,
		);
	},
	'Set the test cache key.',
);

my $retrieved_value;
lives_ok(
	sub
	{
		$retrieved_value = DBIx::NinjaORM::Test->get_cache(
			key => 'test_get_cache',
		);
	},
	'Retrieve the value associated with the test cache key.',
);

is(
	$retrieved_value,
	$test_value,
	'The retrived value matches the set value.',
);


# Test subclass, with the memcache object to use.
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
	
	$info->{'memcache'} = LocalTest::get_memcache();
	
	return $info;
}

1;
