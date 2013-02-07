use strict;
use warnings;
use utf8;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 4;
use Unicode::Util qw( grapheme_length );

# Unicode::Util tests for grapheme_length

is grapheme_length("\x{44E}\x{301}"), 1, 'graphemes in grapheme cluster';
is grapheme_length('abc'),            3, 'graphemes in ASCII string';
is grapheme_length(undef), undef, 'return undef when called on undef';

$_ = "\x{44E}\x{301}";
is grapheme_length(), 1, 'graphemes in grapheme cluster using $_';
