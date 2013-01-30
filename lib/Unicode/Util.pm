package Unicode::Util;

use 5.008;
use strict;
use warnings;
use utf8;
use parent 'Exporter';
use Encode qw( encode find_encoding );
use Unicode::Normalize qw( normalize );
use Scalar::Util qw( looks_like_number );

our $VERSION = '0.07_1';
our @EXPORT_OK = qw(
    grapheme_length
    grapheme_chop
    grapheme_reverse
    grapheme_split
    grapheme_index
    grapheme_rindex
    graph_length graph_chop graph_reverse
    byte_length code_length code_chop
);
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    length => [qw( graph_length code_length byte_length )], # deprecated
);

use constant DEFAULT_ENCODING => 'UTF-8';
use constant IS_NORMAL_FORM   => qr{^ (?:NF)? K? [CD] $}xi;

# deprecated aliases
*graph_length  = \&grapheme_length;
*graph_chop    = \&grapheme_chop;
*graph_reverse = \&grapheme_reverse;

sub grapheme_length {
    my ($str) = @_;
    utf8::upgrade($str);
    return scalar( () = $str =~ m/\X/g );
}

# code_length and byte_length are deprecated: they’re easy to do using core
# syntax and this module will only implement grapheme cluster functions going
# forward
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

sub grapheme_chop {
    my ($str) = @_;
    utf8::upgrade($str);
    $str =~ s/(\X)\z//;
    return $str;
}

# code_chop is deprecated: it’s easy to do using core syntax and this module
# will only implement grapheme cluster functions going forward
sub code_chop {
    my ($str) = @_;
    utf8::upgrade($str);
    chop $str;
    return $str;
}

sub grapheme_reverse {
    my ($str) = @_;
    utf8::upgrade($str);
    my $reverse = '';

    while ( $str =~ s/(\X)\z// ) {
        $reverse .= $1;
    }

    return $reverse;
}

sub grapheme_split {
    my ($str) = @_;
    utf8::upgrade($str);
    my @graphs = $str =~ m/(\X)/g;
    return @graphs;
}

sub grapheme_index {
    my ($str, $substr, $pos) = @_;
    utf8::upgrade($str);
    utf8::upgrade($substr);

    if (!looks_like_number($pos) || $pos < 0) {
        $pos = 0;
    }
    elsif ($pos > (my $graphs = grapheme_length($str))) {
        $pos = $graphs;
    }

    if ($str =~ m{^ ( \X{$pos} \X*? ) \Q$substr\E }xg) {
        return grapheme_length($1);
    }
    else {
        return -1;
    }
}

sub grapheme_rindex {
    my ($str, $substr, $pos) = @_;
    utf8::upgrade($str);
    utf8::upgrade($substr);

    if (!looks_like_number($pos) || $pos < 0) {
        $pos = 0;
    }

    if ($pos) {
        # TODO: replace with grapheme_substr
        $str = substr $str, 0, $pos + ($substr ? 1 : 0);
    }

    if ($str =~ m{^ ( \X* ) \Q$substr\E }xg) {
        return grapheme_length($1);
    }
    else {
        return -1;
    }
}

1;

__END__

=encoding UTF-8

=head1 NAME

Unicode::Util - Unicode grapheme-level versions of built-in Perl functions

=head1 VERSION

This document describes Unicode::Util version 0.07_1.

=head1 SYNOPSIS

    use Unicode::Util qw( grapheme_length grapheme_reverse grapheme_split );

    # grapheme cluster ю́ (Cyrillic small letter yu, combining acute accent)
    my $grapheme = "\x{044E}\x{0301}";

    say length($grapheme);           # 2 (length in code points)
    say grapheme_length($grapheme);  # 1 (length in grapheme clusters)

    # Spın̈al Tap; n̈ = Latin small letter n, combining diaeresis
    my $band = "Sp\x{0131}n\x{0308}al Tap";

    say scalar reverse $band;     # paT länıpS
    say grapheme_reverse($band);  # paT lan̈ıpS

    say join ' ', split //, $band;        # S p ı n ̈ a l   T a p
    say join ' ', grapheme_split($band);  # S p ı n̈ a l   T a p

=head1 DESCRIPTION

This module provides Unicode grapheme cluster–level versions of Perl’s
built-in string functions, tailored to work on grapheme clusters as opposed to
code points or bytes.

=head1 FUNCTIONS

Functions may each be exported explicitly or by using the C<:all> tag for
everything.

=over

=item grapheme_length($string)

Returns the length of the given string in grapheme clusters.  This is the
closest to the number of “characters” that many people would count on a
printed string.

=item grapheme_chop($string)

Returns the given string with the last grapheme cluster chopped off.  Does not
modify the original value, unlike the built-in C<chop>.

=item grapheme_reverse($string)

Returns the given string value with all grapheme clusters in the opposite
order.

=item grapheme_split($string)

Splits a string into a list of strings for each grapheme cluster and returns
that list.  This is similar to C<split(//, $string)>, except that it splits
between grapheme clusters.

=item grapheme_index($string, $substring)

=item grapheme_index($string, $substring, $position)

Searches for one string within another and returns the position in grapheme
clusters of the first occurrence of C<$substring> in C<$string> at or after
the optional grapheme cluster C<$position>.  If the position is omitted,
starts searching from the beginning of the string.  A position before the
beginning of the string or after its end is treated as if it were the
beginning or the end, respectively.  The position and return value are based
at zero.  If the substring is not found, C<grapheme_index> returns C<-1>.

=item grapheme_rindex($string, $substring)

=item grapheme_rindex($string, $substring, $position)

Works just like C<grapheme_index> except that it returns the position in
grapheme clusters of the last occurrence of C<$substring> in C<$string>.  If
C<$position> is specified, returns the last occurrence beginning at or before
that position in grapheme clusters.

=back

=head1 TODO

C<grapheme_substr>, C<canonical_eq>, C<compatibility_eq>

=head1 SEE ALSO

L<Unicode::GCString>, L<String::Multibyte>, L<Perl6::Str>,
L<http://perlcabal.org/syn/S32/Str.html>

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 COPYRIGHT AND LICENSE

© 2011–2013 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
