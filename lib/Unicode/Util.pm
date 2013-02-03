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
    grapheme_index
    grapheme_rindex
    grapheme_split
    graph_length graph_chop graph_reverse
    byte_length code_length code_chop
);
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    length => [qw( graph_length code_length byte_length )], # deprecated
);

use constant DEFAULT_ENCODING => 'UTF-8';
use constant IS_NORMAL_FORM   => qr{^ (?:NF)? K? [CD] $}xi;

sub grapheme_length {
    my ($str) = @_;
    utf8::upgrade($str);
    return scalar( () = $str =~ m{ \X }xg );
}

sub grapheme_chop {
    my ($str) = @_;
    utf8::upgrade($str);
    $str =~ s{ \X \z }{}x;
    return $str;
}

sub grapheme_reverse {
    my ($str) = @_;
    utf8::upgrade($str);
    return join '', reverse $str =~ m{ \X }xg;
}

# experimental functions

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

    if ($str =~ m{ ^ ( \X{$pos} \X*? ) \Q$substr\E }xg) {
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

    if ($str =~ m{ ^ ( \X* ) \Q$substr\E }xg) {
        return grapheme_length($1);
    }
    else {
        return -1;
    }
}

sub grapheme_split {
    my ($str) = @_;
    utf8::upgrade($str);
    my @graphs = $str =~ m{ \X }xg;
    return @graphs;
}

# deprecated functions

sub graph_length {
    my ($str) = @_;
    utf8::upgrade($str);
    return scalar( () = $str =~ m{ \X }xg );
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
    $str =~ s{ \X \z }{}x;
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
    return join '', reverse $str =~ m{ \X }xg;
}

1;

__END__

=encoding UTF-8

=head1 NAME

Unicode::Util - Unicode grapheme-level versions of built-in Perl functions

=head1 VERSION

This document describes Unicode::Util version 0.07_1.

=head1 SYNOPSIS

    use Unicode::Util qw( grapheme_length grapheme_reverse );

    # grapheme cluster ю́ (Cyrillic small letter yu, combining acute accent)
    my $grapheme = "\x{044E}\x{0301}";

    say length($grapheme);           # 2 (length in code points)
    say grapheme_length($grapheme);  # 1 (length in grapheme clusters)

    # Spın̈al Tap; n̈ = Latin small letter n, combining diaeresis
    my $band = "Sp\x{0131}n\x{0308}al Tap";

    say scalar reverse $band;     # paT länıpS
    say grapheme_reverse($band);  # paT lan̈ıpS

=head1 DESCRIPTION

This module provides Unicode grapheme cluster–level versions of Perl’s
built-in string functions, tailored to work on grapheme clusters as opposed to
code points or bytes.  Grapheme clusters correspond to user-perceived characters
and may consist of multiple code points.

=head1 FUNCTIONS

Functions may each be exported explicitly or by using the C<:all> tag for
everything.

=over

=item grapheme_length($string)

=item grapheme_length

Returns the length in graphemes clusters of the value of C<$string>.  If
C<$string> is omitted, returns the length of C<$_>.  If C<$string> is undefined,
returns C<undef>.

=item grapheme_chop($string)

=item grapheme_chop(@list)

=item grapheme_chop(%hash)

=item grapheme_chop

Chops off the last grapheme cluster of a string and returns the grapheme cluster
chopped.  If C<$string> is omitted, chops C<$_>.

If you chop a list, each element is chopped.  Only the value of the last element
is returned.  If you chop a hash, it chops the hash’s values, but not its keys.

You can actually chop anything that’s an lvalue, including an assignment.

Note that C<grapheme_chop> returns the last grapheme cluster.  To return all but
the last grapheme cluster, use C<grapheme_substr($string, 0, -1)>.

=item grapheme_reverse(@list)

In list context, returns a list value consisting of the elements
of C<@list> in the opposite order.  Concatenates the elements of C<@list> and returns a string value with all
grapheme clusters in the opposite order.

    say join ', ', graphe_reverse 'world', 'Hello';  # Hello, world
    say scalar grapheme_reverse 'dlrow ,', 'olleH';  # Hello, world

Used without arguments in scalar context, C<grapheme_reverse> reverses C<$_>.

    $_ = 'dlrow ,olleH';
    print grapheme_reverse;         # No output, list context
    print scalar grapheme_reverse;  # Hello, world

Note that reversing an array to itself (as in C<@a = reverse @a>) will preserve
non-existent elements whenever possible; i.e., for non-magical arrays or for
tied arrays with C<EXISTS> and C<DELETE> methods.

This operator is also handy for inverting a hash, although there are some
caveats.  If a value is duplicated in the original hash, only one of those can
be represented as a key in the inverted hash.  Also, this has to unwind one hash
and build a whole new one, which may take some time on a large hash, such as
from a DBM file.

    %by_name = grapheme_reverse %by_address;  # Invert the hash

=item grapheme_index($string, $substring, $position)

=item grapheme_index($string, $substring)

The C<grapheme_index> function searches for one string within another, but
without the wildcard-like behavior of a full regular-expression pattern match.
It returns the position ig grapheme clusters of the first occurrence of
C<$substring> in C<$string> at or after the grapheme cluster C<$position>.  If
C<$position> is omitted, starts searching from the beginning of the string.
C<$position> before the beginning of the string or after its end is treated as
if it were the beginning or the end, respectively.  C<$position> and the return
value are based at zero.  If the substring is not found, C<index> returns C<-1>.

=item grapheme_rindex($string, $substring, $position)

=item grapheme_rindex($string, $substring)

Works just like C<grapheme_index> except that it returns the position in
grapheme clusters of the I<last> occurrence of C<$substring> in C<string>.  If
C<$position> is specified, returns the last occurrence beginning at or before
that position in grapheme clusters.

=item grapheme_substr($string, $offset, $length, $replacement)

=item grapheme_substr($string, $offset, $length)

=item grapheme_substr($string, $offset)

Extracts a substring out of C<$string> and returns it.  First grapheme cluster
is at offset zero.  If C<$offset> is negative, starts that far back in grapheme
clusters from the end of the string.  If C<$length> is omitted, returns
everything through the end of the string.  If C<$length> is negative, leaves
that many grapheme clusters off the end of the string.

    my $s = 'The black cat climbed the green tree';
    my $color  = grapheme_substr $s, 4, 5;    # black
    my $middle = grapheme_substr $s, 4, -11;  # black cat climbed the
    my $end    = grapheme_substr $s, 14;      # climbed the green tree
    my $tail   = grapheme_substr $s, -4;      # tree
    my $z      = grapheme_substr $s, -4, 2;   # tr

You can use the C<grapheme_substr> function as an lvalue, in which case
C<$string> must itself be an lvalue.  If you assign something shorter than
C<$length>, the string will shrink, and if you assign something longer than
C<$length>, the string will grow to accommodate it.  To keep the string the same
length, you may need to pad or chop your value using C<sprintf>.

If C<$offset> and C<$length> specify a substring that is partly outside the
string, only the part within the string is returned.  If the substring is beyond
either end of the string, C<graphame_substr> returns the undefined value and
produces a warning.  When used as an lvalue, specifying a substring that is
entirely outside the string raises an exception.  Here’s an example showing the
behavior for boundary cases:

    my $name = 'fred';
    grapheme_substr($name, 4) = 'dy';        # $name is now 'freddy'
    my $null = grapheme_substr $name, 6, 2;  # returns '' (no warning)
    my $oops = grapheme_substr $name, 7;     # returns undef, with warning
    grapheme_substr($name, 7) = 'gap';       # raises an exception

An alternative to using C<grapheme_substr> as an lvalue is to specify the
replacement string as the 4th argument.  This allows you to replace parts of the
C<$string> and return what was there before in one operation, just as you can
with C<splice>.

    my $s = 'The black cat climbed the green tree';
    my $z = graphe_substr $s, 14, 7, 'jumped from';  # climbed
    # $s is now 'The black cat jumped from the green tree'

Note that the lvalue returned by the three-argument version of C<substr> acts as
a “magic bullet”; each time it is assigned to, it remembers which part of the
original string is being modified; for example:

    $x = '1234';
    for ( grapheme_substr($x, 1, 2) ) {
        $_ = 'a';   say $x;  # prints 1a4
        $_ = 'xyz'; say $x;  # prints 1xyz4
        $x = '56789';
        $_ = 'pq';  say $x;  # prints 5pq9
    }

With negative offsets, it remembers its position in grapheme clusters from the
end of the string when the target string is modified:

    $x = '1234';
    for ( grapheme_substr($x, -3, 2) ) {
        $_ = 'a'; say $x;  # prints 1a4, as above
        $x = 'abcdefg';
        say;               # prints f
    }

=back

=head1 SEE ALSO

L<Unicode::GCString>, L<String::Multibyte>, L<Perl6::Str>,
L<http://perlcabal.org/syn/S32/Str.html>

=head1 AUTHOR

Nick Patch <patch@cpan.org>

=head1 COPYRIGHT AND LICENSE

© 2011–2013 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
