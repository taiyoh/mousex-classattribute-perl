#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

package My::Class;

use Mouse;
use MouseX::ClassAttribute;

class_has Cache => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

has hoge => (
    is => 'rw',
    isa => 'Str',
    default => sub {'hoge'}
);

no Mouse;
no MouseX::ClassAttribute;

package main;

use Data::Dump qw/dump/;
My::Class->Cache->{thing} = 'hoge';

my $obj_A = My::Class->new;
my $obj_B = My::Class->new;

print dump({obj_A => $obj_A->Cache}), "\n";
print dump({obj_B => $obj_B->Cache}), "\n";
