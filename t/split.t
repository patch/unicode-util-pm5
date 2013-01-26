use strict;
use warnings;
use utf8;
use Test::More tests => 10;
use Test::Warn;
use Unicode::Util qw( graph_split );

is_deeply(
    [ graph_split("x\x{44E}\x{44E}\x{301}\x{44E}\x{301}\x{325}") ],  # xю́ю̥́
    [ 'x', "\x{44E}", "\x{44E}\x{301}", "\x{44E}\x{301}\x{325}" ],
    'graph_split splits between graphemes'
);

is_deeply(
    [ graph_split("\x{44E}\x{301}\x{325}") ],  # ю̥́
    [ "\x{44E}\x{301}\x{325}" ],
    'graph_split returns a single grapheme'
);

is_deeply(
    [ graph_split('abc') ],
    [ 'a', 'b', 'c' ],
    'graph_split splits between single-octet characters'
);

is_deeply(
    [ graph_split("abc\n123") ],
    [ 'a', 'b', 'c', "\n", '1', '2', '3' ],
    'graph_split handles newline'
);

is_deeply(
    [ graph_split("abc\n") ],
    [ 'a', 'b', 'c', "\n" ],
    'graph_split handles trailing newline'
);

is_deeply(
    [ graph_split('x') ],
    [ 'x' ],
    'graph_split returns a single-octet character'
);

is_deeply(
    [ graph_split(0) ],
    [ '0' ],
    'graph_split returns 0'
);

is_deeply(
    [ graph_split('') ],
    [ ],
    'graph_split returns empty list for empty string'
);

warning_is {
    is_deeply(
        [ graph_split(undef) ],
        [ ],
        'graph_split returns empty list for undef'
    );
} (
    'Use of uninitialized value in subroutine entry',
    'graph_split warns for undef'
);
