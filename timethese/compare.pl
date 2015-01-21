#!/usr/bin/perl -I../lib
package Foo;
use parent 'Class::Accessor';
use Class::Accessor;

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors('foo');

sub new{ return bless {}, shift;}

sub custom: lvalue
{
    my($self) = @_;
    return $self->{'testfield'};
}

package Bar;
use parent 'Class::Accessor::Fast';
use Class::Accessor::Fast;

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors('bar');

sub new{ return bless {}, shift;}

package main;
use Class::Property::Default;

my $foo = Foo->new();
my $bar = Bar->new();


for( my $i = 0; $i < 3; $i++ )
{
    $foo->custom = $i;
    print "$foo->{'testfield'}\n";
}

use Benchmark qw(timethese);

timethese( 10000000, 
{
    'Class::Property Reading      ' => sub{ $foo->custom; },
    'Class::Property Writing      ' => sub{ $foo->custom = 100; },
    'Class::Accessor Reading      ' => sub{ $foo->get_foo(); },
    'Class::Accessor Writing      ' => sub{ $foo->set_foo(100); },
    'Class::Accessor::Fast Reading' => sub{ $bar->get_bar(); },
    'Class::Accessor::Fast Writing' => sub{ $bar->set_bar(100); },
    'Direct Reading               ' => sub{ $foo->{'testfield'}; },
    'Direct Writing               ' => sub{ $foo->{'testfield'} = 100; },
});


