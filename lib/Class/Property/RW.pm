package Class::Property::RW;
use strict; use warnings FATAL => 'all'; 
#
# This package is prototype. It has no use by itself
#
sub TIESCALAR
{
    my( $class, $object, $field ) = @_;
    return bless \{
        'object' => $object
        , 'field' => $field
    }, $class;
}

sub STORE
{
    my( $self, $value ) = @_;
    ${$self}->{'object'}->{${$self}->{'field'}} = $value;
}

sub FETCH
{
    my( $self ) = @_;
    return ${$self}->{'object'}->{${$self}->{'field'}};
}

sub DESTROY
{
    my( $self ) = @_;
    ${$self} = undef;
}

1;