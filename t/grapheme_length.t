use strict;
use warnings;
use utf8;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 9;
use Test::Warn;
use Unicode::Util qw( grapheme_length );

# Unicode::Util tests for grapheme_length

is grapheme_length("\x{44E}\x{301}"), 1, 'graphemes in grapheme cluster';
is grapheme_length('abc'),            3, 'graphemes in ASCII string';

warning_like {
    is grapheme_length(undef), 0, '0 when called on undef';
} qr{^Use of uninitialized value}, 'warns on undef';

$_ = "\x{44E}\x{301}";
is grapheme_length(),      1, 'graphemes in grapheme cluster using $_';

warning_like {
    is grapheme_length(undef), 0, 'still 0 when called on undef when $_ is set';
} qr{^Use of uninitialized value}, 'warns on undef';

undef $_;

warning_like {
    is grapheme_length(), 0, '0 when called on undef using $_';
} qr{^Use of uninitialized value}, 'warns on undef';
