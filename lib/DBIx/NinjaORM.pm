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

L<DBIx::NinjaORM> is designed with inheritance in mind, and you can subclass
most of its public methods to extend or alter its behavior.

This group of method covers the most commonly subclassed methods, with examples
and use cases.


=head2 static_class_info()

This methods sets defaults as well as general information for a specific class.
It allows for example indicating what table the objects will be related to, or
what database handle to use.

Here's what a typical subclassed C<static_class_info()> would look like:

	sub static_class_info
	{
		my ( $class ) = @_;
		
		# Retrieve defaults coming from higher in the inheritance chain, up
		# to DBIx::NinjaORM->static_class_info().
		my $info = $class->SUPER::static_class_info();
		
		# Set or override information.
		$info->{'table_name'} = 'books';
		$info->{'primary_key_name'} = 'book_id';
		$info->{'default_dbh'} = DBI->connect(
			"dbi:mysql:[database_name]:localhost:3306",
			"[user]",
			"[password]",
		);
		
		# Return the updated information hashref.
		return $info;
	}

Here's the full list of the options that can be set or overridden:

=over 4

=item * default_dbh

The database handle to use when performing queries. The methods that interact
with the database always provide a C<dbh> argument to allow using a specific
database handle, but setting it here means you won't have to systematically
pass that argument.

	$info->{'default_dbh'} = DBI->connect(
		"dbi:mysql:[database_name]:localhost:3306",
		"[user]",
		"[password]",
	);

=item * memcache

Optionally, C<DBIx::NinjaORM> uses memcache to cache objects and queries,
in conjunction with the C<list_cache_time> and C<object_cache_time> arguments.

If you want to enable the cache features, you can set this to a valid
C<Cache::Memcached> object (or a compatible module, such as
C<Cache::Memcached::Fast>).

	$info->{'memcache'} = Cache::Memcached::Fast->new(
		{
			servers =>
			[
				'localhost:11211',
			],
		}
	);

=item * table_name

Mandatory, the name of the table that this class will be the interface for.

	# Interface with a 'books' table.
	$info->{'table_name'} = 'books';

=item * primary_key_name

The name of the primary key on the table specified with C<table_name>.

	$info->{'primary_key_name'} = 'book_id';

=item * list_cache_time

Control the list cache, which is an optional cache system in
C<retrieve_list()> to store how search criteria translate into object IDs.

By default it is disabled (with C<undef>), but it is activated by setting it to
an integer that represents the cache time in seconds.

	# Cache for 10 seconds.
	$info->{'list_cache_time'} = 10;
	
	# Don't cache.
	$info->{'list_cache_time'} = undef;

A good use case for this would be retrieving a list of books for a given author.
We would pass the author ID as a search criteria, and the resulting list of book
objects does not change often. Provided that you can tolerate a 1 hour delay
for a new book to show up associated with a given author, then it makes sense
to set the list_cache_time to 3600 and save most of the queries to find what
book otherwise belongs to the author.

=item * object_cache_time

Control the object cache, which is an optional cache system in
C<retrieve_list()> to store the objects returned and be able to look them up
by object ID.

By default it is disabled (with C<undef>), but it is activated by setting it to
an integer that represents the cache time in seconds.

	# Cache for 10 seconds.
	$info->{'object_cache_time'} = 10;
	
	# Don't cache.
	$info->{'object_cache_time'} = undef;

A good use case for this are objects that are expensive to build. You will see
more in C<retrieve_list()> on how to cache objects.

=item * unique_fields

The list of unique fields on the object.

Note: L<DBIx::NinjaORM> does not support unique indexes made of more than one
field. If you add more than one field in this arrayref, the ORM will treat them
as separate unique indexes.

	# Declare books.isbn as unique.
	$info->{'unique_fields'} = [ 'isbn' ];
	
	# Declare books.isbn and books.upc as unique.
	$info->{'unique_fields'} = [ 'isbn', 'upc' ];

=item * filtering_fields

The list of fields that can be used to filter on in C<retrieve_list()>.

	# Allow filtering based on the book name and author ID.
	$info->{'unique_fields'} = [ 'name', 'author_id' ];

=item * private_fields

The list of fields that cannot be set directly. They will be populated in
C<retrieve_list>, but you won't be able to insert / update / set them directly.

=item * has_created_field

Indicate whether the table has a field name C<created> to store the UNIX time
at which the row was created. Default: 1.

	# The table doesn't have a 'created' field.
	$info->{'has_created_field'} = 0;

=item * has_modified_field

Indicate whether the table has a field name C<modified> to store the UNIX time
at which the row was modified. Default: 1.

	# The table doesn't have a 'modified' field.
	$info->{'has_modified_field'} = 0;
	
=item * cache_key_field

By default, the object cache uses the primary key value to make cached objects
available to look up, but this allows specifying a different field for that
purpose.

For example, you may want to use books.isbn instead of books.book_id to cache
objects:

	$info->{'cache_key_field'} = 'isbn';

=item * verbose

Add debugging and tracing information, 0 by default.

	# Show debugging information for operations on this class.
	$info->{'verbose'} = 1;

=item * verbose_cache_operations

Add information in the logs regarding cache operations and uses.

=back

=cut

sub static_class_info
{
	return
	{
		'default_dbh'              => undef,
		'memcache'                 => undef,
		'table_name'               => undef,
		'primary_key_name'         => undef,
		'list_cache_time'          => undef,
		'object_cache_time'        => undef,
		'unique_fields'            => [],
		'filtering_fields'         => [],
		'private_fields'           => [],
		'has_created_field'        => 1,
		'has_modified_field'       => 1,
		'cache_key_field'          => undef,
		'verbose'                  => 0,
		'verbose_cache_operations' => 0,
	};
}


=head2 new()

C<new()> has two possible uses:

=over 4

=item * Creating a new empty object

	my $object = My::Model::Book->new();

=item * Retrieving a single object from the database.

	# Retrieve by ID.
	my $object = My::Model::Book->new( id => 3 )
		// die 'Book #3 does not exist';
	
	# Retrieve by unique field.
	my $object = My::Model::Book->new( isbn => '9781449303587' )
		// die 'Book with ISBN 9781449303587 does not exist';

=back

As a result, C<new()> accepts the following arguments:

=over 4

=item * id

The ID for the primary key on the underlying table. C<id> is an alias for the
primary key field name.

	my $object = My::Model::Book->new( id => 3 )
		// die 'Book #3 does not exist';

=item * A unique field

Allows passing a unique field and its value, in order to load the
corresponding object from the database.

	my $object = My::Model::Book->new( isbn => '9781449303587' )
		// die 'Book with ISBN 9781449303587 does not exist';

=item * skip_cache (default: 0)

By default, if cache is enabled with C<object_cache_time()> in
C<static_class_info()>, then C<new> attempts to load the object from the cache
first. Setting C<skip_cache> to 1 forces the ORM to load the values from the
database.

	my $object = My::Model::Book->new(
		isbn       => '9781449303587',
		skip_cache => 1,
	) // die 'Book with ISBN 9781449303587 does not exist';

=item * lock (default: 0)

By default, the underlying row is not locked when retrieving an object via
C<new()>. Setting C<lock> to 1 forces the ORM to bypass the cache if any, and
to lock the rows in the database as it retrieves them.

	my $object = My::Model::Book->new(
		isbn => '9781449303587',
		lock => 1,
	) // die 'Book with ISBN 9781449303587 does not exist';

=back

=cut

sub new
{
	my ( $class, %args ) = @_;
	
	# Check if we have a unique identifier passed.
	# Note: passing an ID is a subcase of passing field defined as unique, but
	# unique_fields() doesn't include the primary key name.
	my $unique_field;
	foreach my $field ( 'id', @{ $class->get_unique_fields() } )
	{
		next
			if ! exists( $args{ $field } );
		
		# If the field exists in the list of arguments passed, it needs to be
		# defined. Being undefined probably indicates a problem in the calling code.
		croak "Called new() with '$field' declared but not defined"
			if ! defined( $args{ $field } );
		
		# Detect if we're passing two unique fields to retrieve the object. This is
		# obviously bad.
		croak "Called new() with the unique argument '$field', but already found another unique argument '$unique_field'"
			if defined( $unique_field );
		
		$unique_field = $field;
	}
	
	# Retrieve the object.
	my $self;
	if ( defined( $unique_field ) )
	{
		my $objects = $class->retrieve_list(
			$unique_field => $args{ $unique_field },
			skip_cache    => $args{'skip_cache'},
			lock          => $args{'lock'} ? 1 : 0,
		);
		
		my $objects_count = scalar( @$objects );
		if ( $objects_count == 0 )
		{
			# No row found.
			$self = undef;
		}
		elsif ( $objects_count == 1 )
		{
			$self = $objects->[0];
		}
		else
		{
			croak "Called new() with a set of non-unique arguments that returned $objects_count objects: " . Dumper( \%args );
		}
	}
	else
	{
		$self = bless( {}, $class );
	}
	
	return $self;
}


=head2 commit()

Convenience function to insert or update the object.

If the object has a primary key set, C<update()> is called, otherwise
C<insert()> is called. If there's an error, the method with croak with
relevant error information.

	$book->commit();

Arguments: (none).

=cut

sub commit
{
	my ( $self ) = @_;
	my $data = Storable::dclone( $self );
	
	if ( defined( $self->id() ) )
	{
		
		my $primary_key_name = $self->get_primary_key_name();
		delete( $data->{ $primary_key_name } )
			if exists( $data->{ $primary_key_name } );
		
		return $self->update( $data );
	}
	else
	{
		return $self->insert( $data );
	}
}


=head2 remove()

Delete in the database the row corresponding to the current object.

	$book->remove();

This method accepts the following arguments:

=over 4

=item * dbh

A different database handle from the default specified in C<static_class_info()>.
This is particularly useful if you have separate reader/writer databases.

=back

=cut

sub remove
{
	my ( $self, %args ) = @_;
	
	# Retrieve the metadata for that table.
	my $class = ref( $self );
	my $table_name = $self->get_table_name();
	croak "The table name for class '$class' is not defined"
		if ! defined( $table_name );
	
	my $primary_key_name = $self->get_primary_key_name();
	croak "Missing primary key name for class '$class', cannot delete safely"
		if !defined( $primary_key_name );
	
	croak "The object of class '$class' does not have a primary key value, cannot update"
		if ! defined( $self->id() );
	
	# Allow using a different DB handle.
	my $dbh = $self->assert_dbh( $args{'dbh'} );
	
	# Delete the row.
	local $dbh->{'RaiseError'} = 1;
	my $deleted = $dbh->do(
		sprintf(
			q|
				DELETE
				FROM %s
				WHERE %s = ?
			|,
			$dbh->quote_identifier( $table_name ),
			$dbh->quote_identifier( $primary_key_name ),
		),
		{},
		$self->id(),
	);
	
	return;
}


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
