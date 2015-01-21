package Class::Property::RW::Lazy;
use strict; use warnings FATAL => 'all'; 
use parent 'Class::Property::RW';

sub TIESCALAR
{
    my( $class, $object, $field, $init, $flag_ref ) = @_;
    return bless \{
        'object' => $object
        , 'field' => $field
        , 'init' => $init
        , 'flag_ref' => $flag_ref
    }, $class;
}

sub STORE
{
    my( $self, $value ) = @_;
    ${$self}->{'object'}->{${$self}->{'field'}} = $value;
    ${${$self}->{'flag_ref'}}++ unless ${${$self}->{'flag_ref'}};
    return;
}

sub FETCH
{
    my( $self ) = @_;
    
    if( not ${${$self}->{'flag_ref'}} )
    {
        ${$self}->{'object'}->{${$self}->{'field'}} = ${$self}->{'init'}->(${$self}->{'object'});
        ${${$self}->{'flag_ref'}}++;
    }
    
    return ${$self}->{'object'}->{${$self}->{'field'}};
}

1;