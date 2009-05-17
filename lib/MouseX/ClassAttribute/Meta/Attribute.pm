package MouseX::ClassAttribute::Meta::Attribute;

use strict;
use warnings;
use utf8;

use base qw/Mouse::Meta::Attribute/;
use Carp 'confess';
use MouseX::ClassAttribute::Meta::Method::Accessor;

sub create_classdata {
    my ( $self, $class, $name, %args ) = @_;

    $args{name}             = $name;
    $args{associated_class} = $class;

    %args = $self->canonicalize_args( $name, %args );
    $self->validate_args( $name, \%args );

    $args{should_coerce} = delete $args{coerce}
        if exists $args{coerce};

    if ( exists $args{isa} ) {
        confess
            "Got isa => $args{isa}, but Mouse does not yet support parameterized types for containers other than ArrayRef and HashRef (rt.cpan.org #39795)"
            if $args{isa} =~ /^([^\[]+)\[.+\]$/
                && $1 ne 'ArrayRef'
                && $1 ne 'HashRef'
                && $1 ne 'Maybe';

        my $type_constraint = delete $args{isa};
        $args{type_constraint}
            = Mouse::Util::TypeConstraints::find_or_create_isa_type_constraint(
            $type_constraint);
    }

    my $attribute = $self->new( $name, %args );

    $class->add_class_attribute($attribute);

    # install an accessor
    if ( $attribute->_is_metadata eq 'rw' || $attribute->_is_metadata eq 'ro' ) {
        my $code = MouseX::ClassAttribute::Meta::Method::Accessor
            ->generate_accessor_method_inline( $attribute, );
        $class->add_method( $name => $code );
    }

    for my $method (qw/predicate clearer/) {
        my $predicate = "has_$method";
        if ( $attribute->$predicate ) {
            my $generator = "generate_$method";
            my $coderef   = $attribute->$generator;
            $class->add_method( $attribute->$method => $coderef );
        }
    }

    if ( $attribute->has_handles ) {
        my $method_map = $attribute->generate_handles;
        for my $method_name ( keys %$method_map ) {
            $class->add_method( $method_name => $method_map->{$method_name} );
        }
    }

    return $attribute;
}

1;
