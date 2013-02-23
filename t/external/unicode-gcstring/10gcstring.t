use strict;
use warnings;
use utf8;
use open qw( :encoding(UTF-8) :std );
use Test::More tests => 9;
use Unicode::Util qw( grapheme_length grapheme_substr );

my $s = pack('U*', 0x300, 0, 0x0D, 0x41, 0x300, 0x301, 0x3042, 0xD, 0xA, 0xAC00, 0x11A8);
is(grapheme_length($s), 7);

my $string = pack('U*', 0x1112, 0x1161, 0x11AB, 0x1100, 0x1173, 0x11AF);
is(grapheme_length($string), 2);

my $g1 = pack('U*', 0x1112, 0x1161);
my $g2 = pack('U*', 0x11AB, 0x1100, 0x1173, 0x11AF);
is(grapheme_length($g1.$g2), 2);

is(grapheme_substr($string, 1), pack('U*', 0x1100, 0x1173, 0x11AF));
is(grapheme_substr($string, -1), pack('U*', 0x1100, 0x1173, 0x11AF));
is(grapheme_substr($string, 0, -1), pack('U*', 0x1112, 0x1161, 0x11AB));
grapheme_substr($string, -1, 1, "A");
is($string, pack('U*', 0x1112, 0x1161, 0x11AB, 0x41));
grapheme_substr($string, 2, 0, "B");
is($string, pack('U*', 0x1112, 0x1161, 0x11AB, 0x41, 0x42));
grapheme_substr($string, 0, 0, "C");
is($string, pack('U*', 0x43, 0x1112, 0x1161, 0x11AB, 0x41, 0x42));
