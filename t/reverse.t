use strict;
use warnings;
use utf8;
use Test::More tests => 1;
use Unicode::Util qw( grapheme_reverse );

# 'ю́xя̡̅̈' to 'я̡̅̈xю́'
is(
    grapheme_reverse("\x{44E}\x{301}x\x{44F}\x{305}\x{308}\x{321}"),
    "\x{44F}\x{305}\x{308}\x{321}x\x{44E}\x{301}",
    'grapheme_reverse on grapheme clusters'
);
