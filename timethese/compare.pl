#!/usr/bin/perl -I../lib
package Foo;
use parent 'Class::Accessor';

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors('foo');


package Bar;
use parent 'Class::Accessor::Fast';

__PACKAGE__->follow_best_practice();
__PACKAGE__->mk_accessors('bar');


package Baz;
use Class::Property;

sub new{ return bless {}, shift;}

rw_property('test_rw');
ro_property('test_ro');
wo_property('test_wo');

property( 'test_lazy' => {'get_lazy' => \&lazy_init, 'set' => undef } );
sub lazy_init{ return 100; }

property( 'custom' => {'get' => \&my_get, 'set' => \&my_set });

sub my_get{ return shift->{'custom'}; }
sub my_set{ shift->{'custom'} = shift; }

package Far;
use Class::XSAccessor
    replace => 1,
    constructor => 'new',
    lvalue_accessors => {
        test_accessor => 'test_accessor'
    }
;
    

package main;

my $foo = Foo->new();
my $bar = Bar->new();
my $baz = Baz->new();
my $far = Far->new();

for( my $i = 0; $i < 3; $i++ )
{
    $baz->test_rw = $i;
    print "$baz->{'test_rw'}\n";
}

use Benchmark qw(timethese);

printf "Benchmarking for Class::Property %s\n", $Class::Property::VERSION;

timethese( 10000000, 
{
    ' 1. Direct hash read           ' => sub{ my $var = $foo->{'testfield'}; },
    ' 2. Direct hash write          ' => sub{ $foo->{'testfield'} = 100; },
    ' 3. Class::XSAccessor lv read  ' => sub{ my $var = $far->test_accessor; },
    ' 4. Class::XSAccessor lv write ' => sub{ $far->test_accessor = 100; },
    ' 5. Class::Property rw read    ' => sub{ my $var = $baz->test_rw; },
    ' 6. Class::Property rw write   ' => sub{ $baz->test_rw = 100; },
    ' 7. Class::Accessor::Fast read ' => sub{ my $var = $bar->get_bar(); },
    ' 8. Class::Accessor::Fast write' => sub{ $bar->set_bar(100); },
    ' 9. Class::Property lrw read   ' => sub{ my $var = $baz->test_lazy; },
    '10. Class::Property lrw write  ' => sub{ $baz->test_lazy = 100; },
    '11. Class::Accessor read       ' => sub{ my $var = $foo->get_foo(); },
    '12. Class::Accessor write      ' => sub{ $foo->set_foo(100); },
    '13. Class::Property ro read    ' => sub{ my $var = $baz->test_ro; },
    '14. Class::Property wo write   ' => sub{ $baz->test_wo = 100; },
    '15. Class::Property crw read   ' => sub{ my $var = $baz->custom; },
    '16. Class::Property crw write  ' => sub{ $baz->custom = 100; },
});


