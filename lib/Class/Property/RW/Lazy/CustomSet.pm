package Class::Property::RW::Lazy::CustomSet;
use strict; use warnings FATAL => 'all'; 
use parent 'Class::Property::RW';

sub TIESCALAR
{
    my( $class, $object, $field, $init, $setter, $flag_ref ) = @_;
    return bless \{
        'object' => $object
        , 'field' => $field
        , 'init' => $init
        , 'setter' => $setter
        , 'flag_ref' => $flag_ref
    }, $class;
}

sub STORE
{
    my( $self, $value ) = @_;
    ${$self}->{'setter'}->(${$self}->{'object'}, $value );
    ${${$self}->{'flag_ref'}}++ unless ${${$self}->{'flag_ref'}};
    return;
}

sub FETCH
{
    my( $self ) = @_;
    
    if( not ${${$self}->{'flag_ref'}} )
    {
        ${$self}->{'setter'}->(${$self}->{'object'}, ${$self}->{'init'}->(${$self}->{'object'}));
        ${${$self}->{'flag_ref'}}++;
    }
    
    return ${$self}->{'object'}->{${$self}->{'field'}};
}

1;