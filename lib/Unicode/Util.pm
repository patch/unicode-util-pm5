package Unicode::Util;

use 5.008;
use strict;
use warnings;
use utf8;
use parent 'Exporter';
use Encode qw( encode_utf8 );

our $VERSION   = '0.03_1';
our @EXPORT_OK = qw(
    graph_length  code_length  byte_length
    graph_chop    code_chop
    graph_reverse
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

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
    return length encode_utf8($str);
}

sub graph_chop {
    my ($str) = @_;
    utf8::upgrade($str);
    $str =~ s/(\X)\z//;
    return $str;
}

sub code_chop {
    my ($str) = @_;
    utf8::upgrade($str);
    chop $str;
    return $str;
}

sub graph_reverse {
    my ($str) = @_;
    utf8::upgrade($str);
    my $reverse = '';
    while ( $str =~ s/(\X)\z// ) {
        $reverse .= $1;
    }
    return $reverse;
}

1;

__END__

=encoding utf8

=head1 NAME

Unicode::Util - Unicode-aware versions of built-in Perl functions

=head1 VERSION

This document describes Unicode::Util version 0.03_1.

=head1 SYNOPSIS

    use Unicode::Util qw( graph_length code_length byte_length );

    # grapheme cluster ю́: Cyrillic small letter yu + combining acute accent
    my $grapheme = "\x{44E}\x{301}";

    say graph_length($grapheme);  # 1
    say code_length($grapheme);   # 2
    say byte_length($grapheme);   # 4

=head1 DESCRIPTION

This module provides additional versions of Perl’s built-in functions,
tailored to work on three different units:

=over

=item * B<graph:> Unicode extended grapheme clusters (graphemes)

=item * B<code:> Unicode codepoints

=item * B<byte:> 8-bit bytes (octets)

=back

This is an early release and this module is likely to have major revisions.
Only the C<length>-, C<chop>-, and C<reverse>-functions are currently
implemented.  See the L</TODO> section for planned future additions.

=head1 FUNCTIONS

=head2 length

=over

=item graph_length($string)

Returns the length in graphemes of the given string.  This is likely the
number of “characters” that many people would count on a printed string, plus
non-printing characters.

=item code_length($string)

Returns the length in codepoints of the given string.  This is likely the
number of “characters” that many programmers and programming languages would
count in a string.

=item byte_length($string)

Returns the length in bytes of the given string encoded as UTF-8.  This is the
number of bytes that many computers would count when storing a string.

=back

=head2 chop

These do not modify the original value, unlike the built-in C<chop>.

=over

=item graph_chop($string)

Returns the given string with the last grapheme chopped off.

=item code_chop($string)

Returns the given string with the last codepoint chopped off.

=back

=head2 reverse

=over

=item graph_reverse($string)

Returns the given string value with all graphemes in the opposite order.

=back

=head1 TODO

Evaluate the following core Perl functions and operators for the potential
addition to this module.

C<split>, C<substr>, C<index>, C<rindex>,
C<eq>, C<ne>, C<lt>, C<gt>, C<le>, C<ge>, C<cmp>

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 COPYRIGHT AND LICENSE

© 2011–2012 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
