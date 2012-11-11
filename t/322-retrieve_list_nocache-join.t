#!perl -T

use strict;
use warnings;

use DBIx::NinjaORM;
use Test::Exception;
use Test::More tests => 7;
use Test::Type;


ok(
	defined(
		my $account = DBIx::NinjaORM::Account->new()
	),
	'Create a new account object.',
);

lives_ok(
	sub
	{
		$account->insert(
			{
				email => 'aubertg@cpan.org',
			}
		);
	},
	'Insert the account.',
);

ok(
	my $object = DBIx::NinjaORM::Test->new(),
	'Create new test object.',
);

my $test_name = 'join_' . time();
lives_ok(
	sub
	{
		$object->insert(
			{
				name       => $test_name,
				account_id => $account->id(),
			}
		);
	},
	'Insert the test object.',
);

my $objects;
lives_ok(
	sub
	{
		$objects = DBIx::NinjaORM::Test->retrieve_list_nocache(
			name => $test_name,
		);
	},
	'Retrieve the objects matching the name.',
);

is(
	scalar( @$objects ),
	1,
	'Retrieved one object.',
) || diag( explain( $objects ) );

is(
	$objects->[0]->{'_account'}->{'email'},
	'aubertg@cpan.org',
	'The email retrieved via a join is correct.',
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

sub retrieve_list_nocache
{
	my ( $class, %args ) = @_;

	return $class->SUPER::retrieve_list_nocache(
		%args,
		query_extensions =>
		{
			joins         =>
			q|
				LEFT JOIN accounts ON accounts.account_id = tests.account_id
			|,
			joined_fields =>
			q|
				accounts.email AS _account_email
			|,
		},
	);
}

1;


package DBIx::NinjaORM::Account;

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
	$info->{'table_name'} = 'accounts';
	$info->{'primary_key_name'} = 'account_id';
	
	return $info;
}

1;
