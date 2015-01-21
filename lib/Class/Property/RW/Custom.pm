package Class::Property::RW::Custom;
use strict; use warnings FATAL => 'all'; 
use parent 'Class::Property::RW';

sub TIESCALAR
{
    my( $class, $object, $getter, $setter ) = @_;
    return bless \{
        'object' => $object
        , 'getter' => $getter
        , 'setter' => $setter
    }, $class;
}

sub STORE
{
    my( $self, $value ) = @_;
    ${$self}->{'setter'}->(${$self}->{'object'},  $value);
}

sub FETCH
{
    my( $self ) = @_;
    return ${$self}->{'getter'}->(${$self}->{'object'});
}

1;