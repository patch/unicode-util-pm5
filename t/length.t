use strict;
use warnings;
use utf8;
use Test::More tests => 6;
use Unicode::Util qw( graph_length code_length byte_length );

my $grapheme = "\x{44E}\x{301}";  # ю́

is graph_length($grapheme), 1, 'graphemes in grapheme cluster';
is code_length($grapheme),  2, 'codepoints in grapheme cluster';
is byte_length($grapheme),  4, 'bytes in grapheme cluster';

my $ascii = 'abc';

is graph_length($ascii), 3, 'graphemes in ASCII string';
is code_length($ascii),  3, 'codepoints in ASCII string';
is byte_length($ascii),  3, 'bytes in ASCII string';
