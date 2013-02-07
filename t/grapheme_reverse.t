use strict;
use warnings;
use utf8;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 4;
use Unicode::Util qw( grapheme_reverse );

# Unicode::Util tests for grapheme_reverse

my $str = "ю\x{0301}xя\x{0305}\x{0308}\x{0321}";  # ю́xя̡̅̈

is(
    scalar grapheme_reverse($str),
    "я\x{0305}\x{0308}\x{0321}xю\x{0301}",  # я̡̅̈xю́
    'grapheme_reverse on string of grapheme clusters in scalar context'
);

is_deeply(
    [grapheme_reverse($str)],
    [$str],
    'grapheme_reverse on string of grapheme clusters in list context'
);

is(
    scalar grapheme_reverse('a', ($str) x 2, 'z'),
    'z' . "я\x{0305}\x{0308}\x{0321}xю\x{0301}" x 2 . 'a',  # zя̡̅̈xю́я̡̅̈xю́a
    'grapheme_reverse on list of strings of grapheme clusters in scalar context'
);

is_deeply(
    [grapheme_reverse('a', ($str) x 2, 'z')],
    ['z', ($str) x 2, 'a'],
    'grapheme_reverse on list of strings of grapheme clusters in list context'
);
