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
    my( $proto, %data ) = @_;
    return bless {%data}, ref $proto || $proto;
}

my $GEN = {
    'default' => sub
    {
        my( $prop_name ) = @_;
        
        return sub: lvalue
        {
            return $_[0]->{$prop_name};
        };
    },
    'custom' => sub
    {
        my( $getter, $setter ) = @_;
        require Class::Property::RW::Custom;
        
        return sub: lvalue
        {
            tie my $val, 'Class::Property::RW::Custom', shift, $getter, $setter;
            return $val;
        };
    },
    'default_get_custom_set' => sub
    {
        my( $prop_name, $setter ) = @_;
        require Class::Property::RW::CustomSet;
        
        return sub: lvalue
        {
            tie my $val, 'Class::Property::RW::CustomSet', shift, $prop_name, $setter;
            return $val;
        };
    },
    'custom_get_default_set' => sub
    {
        my( $prop_name, $getter ) = @_;
        require Class::Property::RW::CustomGet;
        
        return sub: lvalue
        {
            tie my $val, 'Class::Property::RW::CustomGet', shift, $prop_name, $getter;
            return $val;
        };
    },
    'default_ro' => sub
    {
        my( $prop_name ) = @_;
        require Class::Property::RO;
        
        return sub: lvalue
        {
            tie my $val, 'Class::Property::RO', shift, $prop_name;
            return $val;
        };
    },
    'custom_ro' => sub
    {
        my( $prop_name, $getter ) = @_;
        require Class::Property::RO::CustomGet;
        
        return sub: lvalue
        {
            tie my $val, 'Class::Property::RO::CustomGet', shift, $prop_name, $getter;
            return $val;
        };
    },
    'default_wo' => sub: lvalue
    {
        my( $prop_name ) = @_;
        require Class::Property::WO;
        
        return sub: lvalue
        {
            tie my $val, 'Class::Property::WO', shift, $prop_name;
            return $val;
        };
    },
    'custom_wo' => sub: lvalue
    {
        my( $prop_name, $setter ) = @_;
        require Class::Property::WO::CustomSet;
        
        return sub: lvalue
        {
            tie my $val, 'Class::Property::WO::CustomSet', shift, $prop_name, $setter;
            return $val;
        };
    },
};

# creating new property by names
# input is a hash of
# property_name => hashref
# and hashref is:
#
#   get => CODEREF | anything   # creates getter custom or default
#   get_lazy => CODEREF         # creates default getter with lazy init method from CODEREF
#   set => CODREF | anything    # creates custom or default setter 
#
my $make_property = sub
{
    my( $package, %kwargs ) = @_;

    #use Data::Dumper;    warn "Invoked $package with ".Dumper(\%kwargs);
    
    foreach my $prop_name (keys(%kwargs))
    {
        my $prop_settings = $kwargs{$prop_name};
        my $prop_methodname = "${package}::$prop_name";
        my $prop_method;
        
        if( # regular property
            exists $prop_settings->{'get'}
            and exists $prop_settings->{'set'}
        )
        {
            my( $get_type, $set_type ) = ( ref $prop_settings->{'get'}, ref $prop_settings->{'set'} );
            
            if( $get_type eq 'CODE' and $set_type eq 'CODE' ) # custom setter and gettter
            {
                $prop_method = $GEN->{'custom'}->(@{$prop_settings}{'get', 'set'});
            }
            elsif( $get_type eq 'CODE' )    # custom getter and default setter
            {
                $prop_method = $GEN->{'custom_get_default_set'}->($prop_name, @{$prop_settings}{'get'});
            }
            elsif( $set_type eq 'CODE' )    # default getter and custom setter
            {
                $prop_method = $GEN->{'default_get_custom_set'}->($prop_name, @{$prop_settings}{'set'});
            }
            else    # default getter and setter
            {
                $prop_method = $GEN->{'default'}->($prop_name);
            }
        }
        elsif( exists $prop_settings->{'get'} ) # ro property
        {
            if( ref $prop_settings->{'get'} eq 'CODE' ) # RO custom getter
            {
                $prop_method = $GEN->{'custom_ro'}->($prop_name, $prop_settings->{'get'});
            }
            else
            {
                $prop_method = $GEN->{'default_ro'}->($prop_name);
            }
        }
        elsif( exists $prop_settings->{'set'} ) # wo property
        {
            if( ref $prop_settings->{'set'} eq 'CODE' ) # WO custom setter
            {
                $prop_method = $GEN->{'custom_wo'}->($prop_name, $prop_settings->{'set'});
            }
            else
            {
                $prop_method = $GEN->{'default_wo'}->($prop_name);
            }
        }        
        
        if(defined $prop_method)
        {
            no strict 'refs';
            *{$prop_methodname} = $prop_method;
        }
    }
    
    return $package;
};

push @EXPORT, 'property';
sub property{ return $make_property->( (caller)[0], @_);}
push @EXPORT, 'rw_property';
sub rw_property{ return $make_property->( (caller)[0], map{$_ => {'set' => undef, 'get' => undef }} @_);}
push @EXPORT, 'ro_property';
sub ro_property{ return $make_property->( (caller)[0], map{$_ => {'get' => undef }} @_);}
push @EXPORT, 'wo_property';
sub wo_property{ return $make_property->( (caller)[0], map{$_ => {'set' => undef }} @_);}

=pod

=head1 BENCHMARKING

    Direct Reading                :  1 wallclock secs ( 0.39 usr +  0.00 sys =  0.39 CPU) @ 25641025.64/s (n=10000000)
    Direct Writing                :  1 wallclock secs ( 0.73 usr +  0.00 sys =  0.73 CPU) @ 13642564.80/s (n=10000000)
    Class::Accessor::Fast Reading :  3 wallclock secs ( 2.68 usr +  0.00 sys =  2.68 CPU) @ 3727171.08/s (n=10000000)
    Class::Accessor::Fast Writing :  4 wallclock secs ( 3.85 usr +  0.00 sys =  3.85 CPU) @ 2594706.80/s (n=10000000)
    Class::Accessor Reading       :  5 wallclock secs ( 5.76 usr +  0.00 sys =  5.76 CPU) @ 1737317.58/s (n=10000000)
    Class::Accessor Writing       :  6 wallclock secs ( 7.66 usr +  0.00 sys =  7.66 CPU) @ 1305483.03/s (n=10000000)
    Class::Property Reading       : 25 wallclock secs (24.27 usr +  0.00 sys = 24.27 CPU) @ 411980.39/s (n=10000000)
    Class::Property Writing       : 36 wallclock secs (36.16 usr +  0.00 sys = 36.16 CPU) @ 276541.02/s (n=10000000)

=cut

1;