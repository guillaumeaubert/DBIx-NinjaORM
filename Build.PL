use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name          => 'DBIx::NinjaORM',
	license              => 'GPL_3',
	dist_author          => q{Guillaume Aubert <aubertg@cpan.org>},
	dist_version_from    => 'lib/DBIx/NinjaORM.pm',
	build_requires       =>
	{
		'DBD::SQLite'          => 0,
		'DBI'                  => 0,
		'Test::Deep'           => 0,
		'Test::Exception'      => 0,
		'Test::More'           => 0.94, # subtest()
		'Test::Type'           => 0,
		'Try::Tiny'            => 0,
	},
	requires             =>
	{
		'perl'                 => 5.010,
		'Carp'                 => 0,
		'Data::Dumper'         => 0,
		'Data::Validate::Type' => 0,
		'Digest::SHA1'         => 0,
		'MIME::Base64'         => 0,
		'Storable'             => 0,
	},
	add_to_cleanup       =>
	[
		'DBIx-NinjaORM-*',
	],
	create_makefile_pl   => 'traditional',
	configure_requires   =>
	{
		'Module::Build'        => 0,
	},
	meta_merge           =>
	{
		resources              =>
		{
			repository  => 'https://github.com/guillaumeaubert/DBIx-NinjaORM',
			homepage    => 'https://metacpan.org/release/DBIx-NinjaORM',
			bugtracker  => 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=dbix-ninjaorm',
		},
		no_index               =>
		{
			file        =>
			[
				't/lib/LocalTest.pm',
			],
		},
	},
	recursive_test_files => 1,
);

$builder->create_build_script();
