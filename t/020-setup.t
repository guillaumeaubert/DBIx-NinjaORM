#!perl -T

use strict;
use warnings;

use lib 't';
use LocalTest;

use Test::Exception;
use Test::More tests => 5;


my $dbh = LocalTest::ok_database_handle();

my $database_type = LocalTest::ok_database_type( $dbh );

my $schema_file = "t/SQL/setup_$database_type.sql";
ok(
	-e $schema_file,
	"The SQL configuration file for '$database_type' exists.",
);

my $schema;
lives_ok(
	sub
	{
		open( my $fh, '<', $schema_file )
			|| die "Failed to open $schema_file: $!";
		
		$schema = do { local $/ = undef; <$fh> };
		
		close( $fh );
	},
	'Retrieve the SQL schema.',
);

my $statements =
[
	map { s/(^\s+|\s+$)//g; $_ }
	grep { /\w/ }
	split( /;$/m, $schema )
];

subtest(
	'Run SQL statements.',
	sub
	{
		plan( tests => scalar( @$statements ) );
		
		foreach my $statement ( @$statements )
		{
			my ( $name, $sql ) = $statement =~ /^--\s+(.*?)\s+--\s*(.*)$/s;
			$name ||= 'Run statement.';
			$sql ||= $statement;
			
			diag( $sql );
			lives_ok(
				sub
				{
					$dbh->do( $sql );
				},
				$name,
			);
		}
	}
);

