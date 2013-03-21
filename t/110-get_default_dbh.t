#!perl -T

=head1 PURPOSE

Make sure that get_default_dbh() returns the database handle
specified in the static class information.

=cut

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 5;
use Test::NoWarnings;


# Make sure that get_default_dbh() is supported by DBIx::NinjaORM.
can_ok(
	'DBIx::NinjaORM',
	'get_default_dbh',
);

# Verify inheritance.
can_ok(
	'DBIx::NinjaORM::Test',
	'get_default_dbh',
);

my $tests =
[
	# We need to support $class->get_default_dbh() calls.
	{
		name => 'Test calling get_default_dbh() on the class',
		ref  => 'DBIx::NinjaORM::Test',
	},
	# We need to support $object->get_default_dbh() calls.
	{
		name => 'Test calling get_default_dbh() on an object',
		ref  => bless( {}, 'DBIx::NinjaORM::Test' ),
	},
];

# Run tests.
foreach my $test ( @$tests )
{
	subtest(
		$test->{'name'},
		sub
		{
			plan( tests => 2 );
			
			my $default_dbh;
			lives_ok(
				sub
				{
					$default_dbh = $test->{'ref'}->get_default_dbh();
				},
				'Retrieve the default database handle.',
			);
			
			is(
				$default_dbh,
				'TESTDBH',
				'get_default_dbh() returns the value set up in static_class_info().',
			);
		}
	);
}


# Test subclass with a custom 'default_dbh' key.
package DBIx::NinjaORM::Test;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


sub static_class_info
{
	return
	{
		# We're not going to use the database handle, we just need to
		# be able to compare the value, so it's easier here to set it
		# to a known value.
		'default_dbh' => "TESTDBH",
	};
}

1;

