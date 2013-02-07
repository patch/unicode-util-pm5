use strict;
use warnings;
use utf8;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 7;
use Unicode::Util qw( grapheme_chop );

# Unicode::Util tests for grapheme_chop

my $str = "xя\x{0308}ю\x{0301}";  # xя̈ю́

is grapheme_chop($str), "ю\x{301}", 'grapheme_chop returns the last grapheme';
is $str, "xя\x{0308}", 'grapheme_chop removes the last grapheme';

$_ = $str;
is grapheme_chop(), "я\x{0308}", 'grapheme_chop returns the last grapheme using $_';
is $_, 'x', 'grapheme_chop removes the last grapheme using $_';

my @strings = ("xя\x{0308}", "xю\x{0301}");
is grapheme_chop(@strings), "ю\x{301}",
    'grapheme_chop returns the last grapheme of the last element of an array';
is_deeply \@strings, ['x', 'x'],
    'grapheme_chop removes the last grapheme of each element of an array';

@strings = ();
is grapheme_chop(@strings), undef,
    'grapheme_chop returns undef when passed an empty array';
