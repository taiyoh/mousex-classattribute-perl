package MouseX::ClassAttribute;

our $VERSION = '0.002';

use Mouse;
use Exporter 'import';
our @EXPORT = 'class_has';

use MouseX::ClassAttribute::Meta::Attribute;
use MouseX::ClassAttribute::Meta::Class;
use MouseX::ClassAttribute::Meta::Method::Accessor;

sub class_has {
    my $meta = Mouse::Meta::Class->initialize(caller);
    $meta->add_class_attribute(@_);
}

sub unimport {
    my $caller = caller;

    no strict 'refs';
    for my $keyword (@EXPORT) {
        delete ${ $caller . '::' }{$keyword};
    }
}

1;
__END__

=head1 NAME

MouseX::ClassAttribute -

=head1 SYNOPSIS

  use MouseX::ClassAttribute;

=head1 DESCRIPTION

MouseX::ClassAttribute is

=head1 AUTHOR

taiyoh E<lt>sun.basix@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
