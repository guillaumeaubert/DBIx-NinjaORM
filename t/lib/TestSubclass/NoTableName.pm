package TestSubclass::NoTableName;

use strict;
use warnings;

use base 'DBIx::NinjaORM';


=head1 NAME

TestSubclass::NoTableName - Test L<DBIx::NinjaORM> subclass without a table name.


=head1 VERSION

Version 2.5.1

=cut

our $VERSION = '2.5.1';


=head1 SYNOPSIS

	use lib 't/lib';
	use TestSubclass::NoTableName;


=head1 DESCRIPTION

Test subclass without a primary key name defined, which should not allow
inserting rows.


=head1 FUNCTIONS

=head2 static_class_info()

Configure static class information.

=cut

sub static_class_info
{
	my ( $class ) = @_;
	
	my $info = $class->SUPER::static_class_info();
	
	$info->set(
		{
			primary_key_name => 'test_id',
		}
	);
	
	return $info;
}

1;
