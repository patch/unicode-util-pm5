use strict;
use warnings;
use Test::More tests => 4;
use Unicode::Util qw( graph_chop code_chop );

my $grapheme = "x\x{44E}\x{301}";

is graph_chop($grapheme), "\x{44E}\x{301}", 'graph_chop returns last grapheme';
is $grapheme, 'x', 'graph_chop leaves all but last grapheme';

$grapheme = "x\x{44E}\x{301}";

is code_chop($grapheme), "\x{301}", 'code_chop returns last codepoint';
is $grapheme, "x\x{44E}", 'code_chop leaves all but last codepoint';
