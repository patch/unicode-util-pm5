use strict;
use warnings;
use utf8;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 2;
use Unicode::Util qw( grapheme_chop );

# Unicode::Util tests for grapheme_chop

my $grapheme = "x\x{44E}\x{301}";  # xю́

is grapheme_chop($grapheme), "\x{44E}\x{301}", 'grapheme_chop returns the last grapheme';
is $grapheme, 'x', 'grapheme_chop removes the last grapheme';
