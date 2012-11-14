package DBIx::NinjaORM;

use warnings;
use strict;

use Carp;
use Data::Dumper;


=head1 NAME

DBIx::NinjaORM - Flexible Perl ORM for easy transitions from inline SQL to objects.


=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';


=head1 DESCRIPTION

Caveat: if you're starting a new project, L<DBIx::NinjaORM> is probably not the
right ORM to use. Look instead at L<DBIx::Class> for example, which has a more
abstract model and can leverage a nicely normalized database schema.

L<DBIx::NinjaORM> was designed with a few goals in mind:

=over 4

=item *

Allow a progressive introduction of a separate Model layer in a legacy codebase.

=item *

Expand objects with data joined from other tables, to do less queries and
prevent lazy-loading of ancillary information.

=item *

Have a short learning curve.

=back


=head1 SYNOPSIS

=head2 Simple example

Let's take the example of a C<My::Model::Book> class that represents a book. You
would start C<My::Model::Book> with the following code:

	package My::Model::Book;
	
	use strict;
	use warnings;
	
	use base 'DBIx::NinjaORM';
	
	use DBI;
	
	sub static_class_info
	{
		my ( $class ) = @_;
		
		# Retrieve defaults from DBIx::Ninja->static_class_info().
		my $info = $class->SUPER::static_class_info();
		
		# Set mandatory defaults.
		$info->{'table_name'} = 'books';
		$info->{'primary_key_name'} = 'book_id';
		$info->{'default_dbh'} = DBI->connect(
			"dbi:mysql:[database_name]:localhost:3306",
			"[user]",
			"[password]",
		);
		
		# Add optional information.
		# Allow filtering SELECTs on books.name.
		$info->{'filtering_fields'} = [ 'name' ];
		
		return $info;
	}
	
	1;

Inheriting with C<use base 'DBIx::NinjaORM'> and creating
C<sub static_class_info> (with a default database handle and a table name)
are the only two requirements to have a working model.


=head2 A more complex model

If you have more than one Model class to create, for example C<My::Model::Book>
and C<My::Model::Library>, you probably want to create a single class
C<My::Model> to hold the defaults and then inherits from that main class.

	package My::Model;
	
	use strict;
	use warnings;
	
	use base 'DBIx::NinjaORM';
	
	use DBI;
	use Cache::Memcached::Fast;
	
	sub static_class_info
	{
		my ( $class ) = @_;
		
		# Retrieve defaults from DBIx::Ninja->static_class_info().
		my $info = $class->SUPER::static_class_info();
		
		# Set defaults common to all your objects.
		$info->{'default_dbh'} = DBI->connect(
			"dbi:mysql:[database_name]:localhost:3306",
			"[user]",
			"[password]",
		);
		$info->{'memcache'} = Cache::Memcached::Fast->new(
			{
				servers =>
				[
					'localhost:11211',
				],
			}
		);
		
		return $info;
	}
	
	1;

The various classes will then inherit from C<My::Model>, and the inherited
defaults will make C<static_class_info()> shorter in the other classes:

	package My::Model::Book;
	
	use strict;
	use warnings;
	
	# Inherit from your base model class, not from DBIx::NinjaORM.
	use base 'My::Model';
	
	sub static_class_info
	{
		my ( $class ) = @_;
		
		# Retrieve defaults from My::Model.
		my $info = $class->SUPER::static_class_info();
		
		# Set mandatory defaults for this class.
		$info->{'table_name'} = 'books';
		$info->{'primary_key_name'} = 'book_id';
		
		# Add optional information.
		# Allow filtering SELECTs on books.name.
		$info->{'filtering_fields'} = [ 'name' ];
		
		return $info;
	}
	
	1;

=cut


=head1 SUPPORTED DATABASES

This distribution currently supports:

=over 4

=item * SQLite

=back

Please contact me if you need support for another database type, I'm always
glad to add extensions if you can help me with testing.


=head1 SUBCLASSABLE METHODS


=head1 UTILITY METHODS


=head1 ACCESSORS


=head1 CACHE RELATED METHODS


=head1 INTERNAL METHODS


=head1 AUTHOR

Guillaume Aubert, C<< <aubertg at cpan.org> >>.


=head1 BUGS

Please report any bugs or feature requests to C<bug-dbix-ninjaorm at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-NinjaORM>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc DBIx::NinjaORM


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-NinjaORM>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-NinjaORM>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-NinjaORM>

=item * Search CPAN

L<http://search.cpan.org/dist/DBIx-NinjaORM/>

=back


=head1 ACKNOWLEDGEMENTS

Thanks to ThinkGeek (L<http://www.thinkgeek.com/>) and its corporate overlords
at Geeknet (L<http://www.geek.net/>), for footing the bill while I write code
for them!


=head1 COPYRIGHT & LICENSE

Copyright 2009-2012 Guillaume Aubert.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3 as published by the Free
Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see http://www.gnu.org/licenses/

=cut

1;
