use strict;
use warnings;
use utf8;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 10;
use Unicode::Util qw( grapheme_chop grapheme_length );

# Unicode::Util tests for grapheme_chop

my $str = "xя\x{0308}ю\x{0301}";  # xя̈ю́

is grapheme_chop($str), "ю\x{301}", 'grapheme_chop returns the last grapheme';
is $str, "xя\x{0308}", 'grapheme_chop removes the last grapheme';

$_ = $str;
is grapheme_chop(), "я\x{0308}", 'grapheme_chop returns the last grapheme using $_';
is $_, 'x', 'grapheme_chop removes the last grapheme using $_';

my @array = ("xя\x{0308}", "xю\x{0301}");
is grapheme_chop(@array), "ю\x{301}",
    'grapheme_chop returns the last grapheme of the last element of an array';
is_deeply \@array, ['x', 'x'],
    'grapheme_chop removes the last grapheme of each element of an array';

undef @array;
is grapheme_chop(@array), undef,
    'grapheme_chop returns undef when passed an empty array';

my %hash = (a => "xя\x{0308}", b => "xю\x{0301}");
is grapheme_length( grapheme_chop(%hash) ), 1,
    'return value of grapheme_chop on a hash is not defined but will be one of the chopped graphemes';
is_deeply \%hash, { a => 'x', b => 'x' },
    'grapheme_chop removes the last grapheme of each element of a hash';

%hash = ();
is grapheme_chop(%hash), undef,
    'grapheme_chop returns undef when passed an empty hash';
