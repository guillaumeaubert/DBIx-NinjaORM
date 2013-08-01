#!perl -T

=head1 PURPOSE

Test inserting in a table, with created/modified being real timestamps as
opposed to the default unixtime format.

=cut

use strict;
use warnings;

use lib 't/lib';

use Class::Load qw();
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Test::More tests => 4;
use TestSubclass::DateTable;


Class::Load::try_load_class( 'POSIX' )
	|| plan( skip_all => 'POSIX is not available on this system.' );

my $object_id;
subtest(
	'Insert test object.',
	sub
	{
		plan( tests => 2 );
		
		ok(
			my $object = TestSubclass::DateTable->new(),
			'Create new object.',
		);

		my $name = 'test_insert_timestamp_' . time();
		lives_ok(
			sub
			{
				$object->insert(
					{
						name => $name,
					}
				)
			},
			'Insert succeeds.',
		);
		
		$object_id = $object->id();
	}
);

ok(
	defined(
		my $object = TestSubclass::DateTable->new( { id => $object_id } )
	),
	'Retrieve the object.',
);

my $now = POSIX::strftime( '%Y-%m-%d %H:%M:%S', gmtime() );

like(
	$object->get('created'),
	qr/$now/,
	'The created field is correctly formatted.',
);

like(
	$object->get('modified'),
	qr/$now/,
	'The modified field is correctly formatted.',
);
