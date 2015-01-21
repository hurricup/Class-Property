#!/usr/bin/perl -It/
# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Class-Property.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use Test::More;
BEGIN { use_ok('Class::Property') };

use Foo;

my $foo = Foo->new(
    'price' => 123
    , 'price_ro' => 456
    , 'price_wo' => 789
    , 'custom_get' => 999
);

is( $foo->price, $foo->{'price'}, 'RW property inited in constructor');
$foo->price = 100;
is( $foo->price, $foo->{'price'}, 'RW property setting via assignment');

is( $foo->price_ro, $foo->{'price_ro'}, 'RO property inited in constructor');
$foo->{'price_ro'} = 456456;
is( $foo->price_ro, $foo->{'price_ro'}, 'RO property set indirectly');

eval{ $foo->price_ro = 123; };
ok( $@ =~ /Unable to set read-only property/, 'RO property writing protection');

eval{ my $var = $foo->price_wo; };
ok( $@ =~ /Unable to read write-only property/, 'WO property reading protection');

$foo->price_wo = 987;
is( $foo->{'price_wo'}, 987, 'WO property setter');

$foo->custom = 150;
is( $foo->{'supercustom'}, 150, 'RW custom property setter' );
is( $foo->{'supercustom'}, $foo->custom, 'RW custom property getter' );

is( $foo->custom_get, $foo->{'custom_get'} + 1, 'RW custom property getter with def setter' );
$foo->custom_get = 123;
is( $foo->custom_get, 123 + 1, 'RW custom property getter with def setter' );


use Bar;
my $bar = Bar->new(
    'price' => 123
    , 'price_ro' => 456
    , 'price_wo' => 789
    , 'price_bar' => 1239
    , 'price_bar_ro' => 4569
    , 'price_bar_wo' => 7899
);

is( $bar->price, $bar->{'price'}, 'Inheritance: RW property inited in constructor');
$bar->price = 100;
is( $bar->price, $bar->{'price'}, 'Inheritance: RW property setting via assignment');

is( $bar->price_ro, $bar->{'price_ro'}, 'Inheritance: RO property inited in constructor');
$bar->{'price_ro'} = 456456;
is( $bar->price_ro, $bar->{'price_ro'}, 'Inheritance: RO property set indirectly');

eval{ $bar->price_ro = 123; };
ok( $@ =~ /Unable to set read-only property/, 'Inheritance: RO property writing protection');

eval{ my $var = $bar->price_wo; };
ok( $@ =~ /Unable to read write-only property/, 'Inheritance: WO property reading protection');

$bar->price_wo = 9871;
is( $bar->{'price_wo'}, 9871, 'Inheritance: WO property setter');

is( $bar->price_bar, $bar->{'price_bar'}, 'Inheritance: RW property inited in constructor');
$bar->price_bar = 100;
is( $bar->price_bar, $bar->{'price_bar'}, 'Inheritance: RW property setting via assignment');

is( $bar->price_bar_ro, $bar->{'price_bar_ro'}, 'Inheritance: RO property inited in constructor');

eval{ my $var = $bar->price_bar_wo; };
ok( $@ =~ /Unable to read write-only property/, 'Inheritance: WO property reading protection');

done_testing();