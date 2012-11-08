#!perl -T

use strict;
use warnings;

use lib 't';
use LocalTest;

use Test::Exception;
use Test::More tests => 4;


my $dbh = LocalTest::ok_database_handle();

my $database_type = LocalTest::ok_database_type( $dbh );

my $table_definitions =
{
	SQLite =>
	q|
		CREATE TABLE tests
		(
			test_id INTEGER PRIMARY KEY AUTOINCREMENT,
			name VARCHAR(32) NOT NULL,
			value VARCHAR(128) DEFAULT NULL,
			created BIGINT(20) NOT NULL DEFAULT '0',
			modified BIGINT(20) NOT NULL DEFAULT '0',
			UNIQUE (name)
		)
	|,
	mysql  =>
	q|
		CREATE TABLE tests
		(
			test_id bigint(20) unsigned NOT NULL auto_increment,
			name varchar(32) NOT NULL,
			value varchar(128) DEFAULT NULL,
			created bigint(20) unsigned NOT NULL default '0',
			modified bigint(20) unsigned NOT NULL default '0',
			PRIMARY KEY (test_id),
			UNIQUE KEY idx_unique_name (name)
		)
	|,
};

ok(
	defined(
		my $table_definition = $table_definitions->{ $database_type }
	),
	'Retrieve table definition for the table type.',
);

lives_ok(
	sub
	{
		$dbh->do(
			$table_definition
		);
	},
	'Create test table.',
);
