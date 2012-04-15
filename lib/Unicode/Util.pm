package Unicode::Util;

use 5.008;
use strict;
use warnings;
use utf8;
use parent 'Exporter';
use Encode qw( encode find_encoding );
use Unicode::Normalize qw( normalize );

our $VERSION   = '0.06';
our @EXPORT_OK = qw(
    graph_length  code_length  byte_length
    graph_chop    code_chop
    graph_reverse
);
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    length => [qw( graph_length code_length byte_length )],
);

use constant DEFAULT_ENCODING => 'UTF-8';
use constant IS_NORMAL_FORM   => qr{^ (?:NF)? K? [CD] $}xi;

sub graph_length {
    my ($str) = @_;
    utf8::upgrade($str);
    return scalar( () = $str =~ m/\X/g );
}

sub code_length {
    my ($str, $nf) = @_;
    utf8::upgrade($str);

    if ($nf && $nf =~ IS_NORMAL_FORM) {
        $str = normalize(uc $nf, $str);
    }

    return length $str;
}

sub byte_length {
    my ($str, $enc, $nf) = @_;
    utf8::upgrade($str);

    if ( !$enc || !find_encoding($enc) ) {
        $enc = DEFAULT_ENCODING;
    }

    if ($nf && $nf =~ IS_NORMAL_FORM) {
        $str = normalize(uc $nf, $str);
    }

    return length encode($enc, $str);
}

sub graph_chop {
    my ($str) = @_;
    utf8::upgrade($str);
    $str =~ s/(\X)\z//;
    return $str;
}

# code_chop is deprecated: it's easy to do using core syntax and this module
# will only implement grapheme cluster functions going forward, except for
# code_length and byte_length
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

=encoding UTF-8

=head1 NAME

Unicode::Util - Unicode-aware versions of built-in Perl functions

=head1 VERSION

This document describes Unicode::Util version 0.06.

=head1 SYNOPSIS

    use Unicode::Util qw( graph_length code_length byte_length );

    # grapheme cluster ю́: Cyrillic small letter yu + combining acute accent
    my $grapheme = "\x{44E}\x{301}";

    say graph_length($grapheme);          # 1
    say code_length($grapheme);           # 2
    say byte_length($grapheme, 'UTF-8');  # 4

=head1 DESCRIPTION

This module provides Unicode-aware versions of Perl’s built-in string
functions, tailored to work on grapheme clusters as opposed to code points or
bytes.

=head1 FUNCTIONS

Functions may each be exported explicitly, or by using the C<:all> tag for
everything or the C<:length> tag for the length functions.

=over

=item graph_length($string)

Returns the length of the given string in grapheme clusters.  This is the
closest to the number of “characters” that many people would count on a
printed string.

=item code_length($string)

=item code_length($string, $normal_form)

Returns the length of the given string in code points.  This is likely the
number of “characters” that many programmers and programming languages would
count in a string.  If the optional Unicode normalization form is supplied,
the length will be of the string as if it had been normalized to that form.

Valid normalization forms are C<C> or C<NFC>, C<D> or C<NFD>, C<KC> or
C<NFKC>, and C<KD> or C<NFKD>.

=item byte_length($string)

=item byte_length($string, $encoding)

=item byte_length($string, $encoding, $normal_form)

Returns the length of the given string in bytes, as if it were encoded using
the specified encoding or UTF-8 if no encoding is supplied.  If the optional
Unicode normalization form is supplied, the length will be of the string as if
it had been normalized to that form.

=item graph_chop($string)

Returns the given string with the last grapheme cluster chopped off.  Does not
modify the original value, unlike the built-in C<chop>.

=item graph_reverse($string)

Returns the given string value with all grapheme clusters in the opposite
order.

=back

=head1 TODO

C<graph_substr>, C<graph_index>, C<graph_rindex>

=head1 SEE ALSO

L<Unicode::GCString>, L<String::Multibyte>, L<Perl6::Str>,
L<http://perlcabal.org/syn/S32/Str.html>

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 COPYRIGHT AND LICENSE

© 2011–2012 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
