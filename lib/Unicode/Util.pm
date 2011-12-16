package Unicode::Util;

use 5.008;
use strict;
use warnings;
use parent 'Exporter';
use Encode qw( encode_utf8 );
use Unicode::Normalize;

our $VERSION   = '0.01';
our @EXPORT_OK = qw(
    graph_length
    code_length
    byte_length
);

sub graph_length {
    my ($str) = @_;
    utf8::upgrade($str);
    return scalar( () = $str =~ m/\X/g );
}

sub code_length {
    my ($str) = @_;
    utf8::upgrade($str);
    return length $str;
}

sub byte_length {
    my ($str) = @_;
    utf8::upgrade($str);
    return length encode_utf8( NFKC($str) );
}

1;

__END__

=encoding utf8

=head1 NAME

Unicode::Util - Grapheme-aware versions of built-in Perl functions

=head1 VERSION

This document describes Unicode::Util version 0.01.

=head1 SYNOPSIS

    ...

=head1 DESCRIPTION

=over

=item graph_length

=item code_length

=item byte_length

=back

=head1 TODO

graph_reverse graph_chop graph_split graph_substr code_substr byte_substr graph_index code_index byte_index graph_rindex code_rindex byte_rindex

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2011 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
