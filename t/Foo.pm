package Foo::Bar;
use Class::Property;
use parent 'Class::Property';

property(
    'price' => { 'get' => undef, 'set' => undef }                               # default setter and getter
    , 'weight' => { 'get' => undef }                                            # default gettter, RO property
    , 'quantity' => { 'set' => undef }                                          # default settter, WO property
    , 'parameters' => { 'get' => \&get_parameters, 'set' => \&set_parameters }  # custom getter and setter
    , 'param2' => { 'lazy' => \&get_param2, 'set' => undef }                    # default lazy getter with get_param2 as lazy init and default setter
);

sub get_parameters
{
    print "get_parameters invoked\n";
}

sub set_parameters
{
    print "set_parameters invoked\n";
}

sub get_param2
{
    print "get_param2 invoked\n";
}

1;
