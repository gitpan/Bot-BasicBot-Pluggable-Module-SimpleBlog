package Bot::BasicBot::Pluggable::Module::SimpleBlog::Store::SQLite;

use strict;
use vars qw( $VERSION );
$VERSION = '0.01';

use base qw(Bot::BasicBot::Pluggable::Module::Base);

use Carp;
use DBD::SQLite;

=head1 NAME

Bot::BasicBot::Pluggable::Module::SimpleBlog::Store::SQLite - SQLite storage for Bot::BasicBot::Pluggable::Module::SimpleBlog.

=head1 SYNOPSIS

  use Bot::BasicBot::Pluggable::Module::SimpleBlog::Store::SQLite;

  my $blog_store =
    Bot::BasicBot::Pluggable::Module::SimpleBlog::Store::SQLite->new(
      "/home/bot/brane.db" );

=head1 DESCRIPTION

Store URLs in a sqlite database for
L<Bot::BasicBot::Pluggable::Module::SimpleBot>.

=head1 METHODS

=over 4

=item B<new>

  my $blog_store =
    Bot::BasicBot::Pluggable::Module::SimpleBlog::Store::SQLite->new(
      "/home/bot/brane.db" );

You must supply a filename writeable by the user the bot runs as. The
file need not already exist; it will be created and the correct
database schema set up as necessary.

Croaks if L<DBD::SQLite> fails to connect to the file.

=cut

sub new {
    my ($class, $filename) = @_;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$filename", "", "")
      or croak "ERROR: Can't connect to sqlite database: " . DBI->errstr;

    my $self = { };
    bless $self, $class;

    $self->{dbh} = $dbh;
    $self->ensure_db_schema_correct or return;
    return $self;
}

sub ensure_db_schema_correct {
    my $self = shift;
    my $dbh  = $self->{dbh};

    my $sql = "SELECT name FROM sqlite_master WHERE type='table'
               AND name='blogged'";
    my $sth = $dbh->prepare($sql)
      or croak "ERROR: " . $dbh->errstr;
    $sth->execute;
    my ($ok) = $sth->fetchrow_array;
    return 1 if $ok;

    $dbh->do("CREATE TABLE blogged
            ( timestamp text, name text, chan text, url text, comment text )" )
      or croak "ERROR: " . $dbh->errstr;
    return 1;
}

=item B<store>

  $store->store( timestamp => $timestamp,
                 name      => $who,
                 channel   => $channel,
                 url       => $url,
                 comment   => $comment );

Stores the given information in the database.  Croaks on error.

=cut

sub store {
    my ($self, %args) = @_;
    my $dbh = $self->{dbh};

    my $sth = $dbh->prepare( qq{
        INSERT INTO blogged (timestamp, name, chan, url, comment)
               VALUES (?, ?, ?, ?, ?)
    }) or return "Error: can't insert into database: " . $dbh->errstr;

    $sth->execute( @args{ qw( timestamp name channel url comment ) } )
      or croak "Error: can't insert into database: " . $dbh->errstr;

    return 1;
}

=head1 BUGS

No tests.

=head1 SEE ALSO

=over 4

=item * L<Bot::BasicBot::Pluggable::Module::SimpleBlog>

=back

=head1 AUTHOR

Kake Pugh (kake@earth.li).

=head1 COPYRIGHT

     Copyright (C) 2003 Kake Pugh.  All Rights Reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
