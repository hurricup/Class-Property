package Class::Property::RW::CustomSet;
use strict; use warnings FATAL => 'all'; 
use parent 'Class::Property::RW';

sub TIESCALAR
{
    my( $class, $object, $field, $setter ) = @_;
    return bless \{
        'object' => $object
        , 'field' => $field
        , 'setter' => $setter
    }, $class;
}

sub STORE
{
    my( $self, $value ) = @_;
    ${$self}->{'setter'}->(${$self}->{'object'}, $value);
}

1;