package MouseX::ClassAttribute::Meta::Class;

use strict;
use warnings;

{
    package Mouse::Meta::Class;

    {
        my %CACHE_CLASS_DATA;

        sub has_class_attribute {
            my $self = shift;
            my $name = shift;
            return !!$CACHE_CLASS_DATA{$self->name}{$name};
        }

        sub get_class_attribute {
            my $self = shift;
            my $name = shift;
            return $CACHE_CLASS_DATA{$self->name};
        }

        sub get_class_attribute_list {
            my $self = shift;
            return keys %{ $CACHE_CLASS_DATA{$self->name} };
        }

        sub get_class_attribute_map {
            my $self = shift;
            return values %{$CACHE_CLASS_DATA{$self->name}};
        }

        #sub add_class_attribute(...)

        sub remove_class_attribute {
            my $self = shift;
            my $name = shift;
            return delete $CACHE_CLASS_DATA{$self->name}{$name};
        }

        sub get_all_class_attributes {
            my $self = shift;
            # ??
            return values %{ $CACHE_CLASS_DATA{$self->name} };
        }

        sub find_class_attribute_by_name {
            my $self = shift;
            my $name = shift;
            for my $cattr (values %CACHE_CLASS_DATA) {
                return $cattr->{$name} if $cattr->{$name};
            }
            return;
        }

        sub get_class_attribute_value {
            my $self = shift;
            my $name = shift;
            return $CACHE_CLASS_DATA{$self->name}{$name};
        }

        sub set_class_attribute_value {
            my $self = shift;
            my ( $name, $value ) = @_;
            $value->{value} ||= ref($value->default) eq 'CODE'
                ? $value->default->($value)
                : $value->default;
            $CACHE_CLASS_DATA{$self->name}{$name} = $value;
        }

        sub clear_class_attribute_value {
            my $self = shift;
            my $name = shift;
            $CACHE_CLASS_DATA{$self->name}{$name} = undef;
        }
    }

    sub add_class_attribute {
        my $self = shift;

        if ( @_ == 1 && blessed( $_[0] ) ) {
            my $attr = shift @_;
            $self->set_class_attribute_value($attr->name, $attr);
        }
        else {
            my $names = shift @_;
            $names = [$names] if !ref($names);
            my $metaclass = 'MouseX::ClassAttribute::Meta::Attribute';
            my %options   = @_;

            if ( my $metaclass_name = delete $options{metaclass} ) {
                my $new_class = Mouse::Util::resolve_metaclass_alias( 'Attribute',
                    $metaclass_name );
                if ( $metaclass ne $new_class ) {
                    $metaclass = $new_class;
                }
            }

            for my $name (@$names) {
                if ( $name =~ s/^\+// ) {
                    #FIXME
                    $metaclass->clone_parent( $self, $name, @_ );
                }
                else {
                    $metaclass->create_classdata( $self, $name, @_ );
                }
            }
        }
    }
}

1;
__END__

