package Class::Property;
use strict; use warnings FATAL => 'all'; 
use parent 'Exporter';
use 5.010;
use Carp;

our $VERSION = 0.01;

our @EXPORT;

# Just blessing passed hash
sub new
{
    my( $proto, $data ) = @_;
    return bless {%{$data // {}}}, ref $proto || $proto;
}

# creating new property by names
# input is a hash of
# property_name => hashref
# and hashref is:
#
#   get => CODEREF | anything   # creates getter custom or default
#   get_lazy => CODEREF         # creates default getter with lazy init method from CODEREF
#   set => CODREF | anything    # creates custom or default setter 
#
push @EXPORT, 'property';
sub property
{
    my( %kwargs ) = @_;
    my( $package ) = (caller)[0];
    printf "Generating properties for $package\n";
    return $package;
}

push @EXPORT, 'lazy';
sub lazy 
{
    return 'default';
}


1;