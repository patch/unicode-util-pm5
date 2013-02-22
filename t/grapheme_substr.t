use strict;
use warnings;
use utf8;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 7;
use Unicode::Util qw( grapheme_substr );

# Unicode::Util tests for grapheme_substr

my $s = 'The black cat climbed the green tree';
is grapheme_substr($s,  4,   5), 'black';
is grapheme_substr($s,  4, -11), 'black cat climbed the';
is grapheme_substr($s, 14),      'climbed the green tree';
is grapheme_substr($s, -4),      'tree';
is grapheme_substr($s, -4, 2),   'tr';

is grapheme_substr($s, 14, 7, 'jumped from'), 'climbed';
is $s, 'The black cat jumped from the green tree';
