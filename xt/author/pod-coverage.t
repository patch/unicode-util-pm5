use strict;
use warnings;
use Test::More;

eval 'use Test::Pod::Coverage 1.00';
plan skip_all => 'Test::Pod::Coverage 1.00 not installed; skipping' if $@;

all_pod_coverage_ok({ trustme => [qw<
    byte_length
    code_chop
    code_length
    graph_chop
    grapheme_index
    grapheme_rindex
    grapheme_split
    graph_length
    graph_reverse
>] });
