package Foo;
use strict;
use Class::Property;
use parent 'Class::Property';

property(
    'custom' => { 'set' => \&custom_setter, 'get' => \&custom_getter },
    'custom_get' => { 'set' => undef, 'get' => \&custom_getter_def },
    'custom_set' => { 'set' => \&custom_setter_def, 'get' => undef },
    'custom_ro' => { 'get' => \&custom_ro_getter },
    'custom_wo' => { 'set' => \&custom_wo_setter },
);

rw_property( 'price', 'price3' );
ro_property( 'price_ro' );
wo_property( 'price_wo' );

sub custom_setter
{
    my( $self, $value) = @_;
    $self->{'supercustom'} = $value;
}

sub custom_getter
{
    return shift->{'supercustom'};
}

sub custom_ro_getter
{
    return shift->{'supercustom_ro'};
}

sub custom_wo_setter
{
    return shift->{'supercustom_wo'};
}

sub custom_getter_def
{
    return shift->{'custom_get'} + 1;
}

sub custom_setter_def
{
    shift->{'custom_set'} = (shift) + 100;
}


1;
