package SharedTests;

use strict;
use warnings;

use Scalar::Util qw( isweak );
use Test::More;


{
    package HasClassAttribute;

    use Moose qw( has );
    use MooseX::ClassAttribute;
    use MooseX::AttributeHelpers;

    use vars qw($Lazy);
    $Lazy = 0;

    class_has 'ObjectCount' =>
        ( is        => 'rw',
          isa       => 'Int',
          default   => 0,
        );

    class_has 'WeakAttribute' =>
        ( is        => 'rw',
          isa       => 'Object',
          weak_ref  => 1,
        );

    class_has 'LazyAttribute' =>
        ( is      => 'rw',
          isa     => 'Int',
          lazy    => 1,
          # The side effect is used to test that this was called
          # lazily.
          default => sub { $Lazy = 1 },
        );

    class_has 'ReadOnlyAttribute' =>
        ( is      => 'ro',
          isa     => 'Int',
          default => 10,
        );

    class_has 'ManyNames' =>
        ( is        => 'rw',
          isa       => 'Int',
          reader    => 'M',
          writer    => 'SetM',
          clearer   => 'ClearM',
          predicate => 'HasM',
        );

    class_has 'Delegatee' =>
        ( is      => 'rw',
          isa     => 'Delegatee',
          handles => [ 'units', 'color' ],
          # if it's not lazy it makes a new object before we define
          # Delegatee's attributes.
          lazy    => 1,
          default => sub { Delegatee->new() },
        );

    class_has 'Mapping' =>
        ( metaclass => 'Collection::Hash',
          is        => 'rw',
          isa       => 'HashRef[Str]',
          default   => sub { {} },
          provides  =>
          { exists => 'ExistsInMapping',
            keys   => 'IdsInMapping',
            get    => 'GetMapping',
            set    => 'SetMapping',
          },
        );

    has 'size' =>
        ( is      => 'rw',
          isa     => 'Int',
          default => 5,
        );

    no Moose;

    sub BUILD
    {
        my $self = shift;

        $self->ObjectCount( $self->ObjectCount() + 1 );
    }

    sub make_immutable
    {
        my $class = shift;

        $class->meta()->make_immutable();
        Delegatee->meta()->make_immutable();
    }
}

{
    package Delegatee;

    use Moose;

    has 'units' =>
        ( is      => 'ro',
          default => 5,
        );

    has 'color' =>
        ( is      => 'ro',
          default => 'blue',
        );

    no Moose;
}

{
    package Child;

    use Moose;
    use MooseX::ClassAttribute;

    extends 'HasClassAttribute';

    class_has '+ReadOnlyAttribute' =>
        ( default => 30 );

    class_has 'YetAnotherAttribute' =>
        ( is      => 'ro',
          default => 'thing',
        );

    no Moose;
}

sub run_tests
{
    plan tests => 24;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    {
        is( HasClassAttribute->ObjectCount(), 0,
            'ObjectCount() is 0' );

        my $hca1 = HasClassAttribute->new();
        is( $hca1->size(), 5,
            'size is 5 - object attribute works as expected' );
        is( HasClassAttribute->ObjectCount(), 1,
            'ObjectCount() is 1' );

        my $hca2 = HasClassAttribute->new( size => 10 );
        is( $hca2->size(), 10,
            'size is 10 - object attribute can be set via constructor' );
        is( HasClassAttribute->ObjectCount(), 2,
            'ObjectCount() is 2' );
        is( $hca2->ObjectCount(), 2,
            'ObjectCount() is 2 - can call class attribute accessor on object' );
    }

    {
        my $hca3 = HasClassAttribute->new( ObjectCount => 20 );
        is( $hca3->ObjectCount(), 3,
            'class attributes passed to the constructor do not get set in the object' );
        is( HasClassAttribute->ObjectCount(), 3,
            'class attributes are not affected by constructor params' );
    }

    {
        my $object = bless {}, 'Thing';

        HasClassAttribute->WeakAttribute($object);

        undef $object;

        ok( ! defined HasClassAttribute->WeakAttribute(),
            'weak class attributes are weak' );
    }

    {
        is( $HasClassAttribute::Lazy, 0,
            '$HasClassAttribute::Lazy is 0' );

        is( HasClassAttribute->LazyAttribute(), 1,
            'HasClassAttribute->LazyAttribute() is 1' );

        is( $HasClassAttribute::Lazy, 1,
            '$HasClassAttribute::Lazy is 1 after calling LazyAttribute' );
    }

    {
        eval { HasClassAttribute->ReadOnlyAttribute(20) };
        like( $@, qr/\QCannot assign a value to a read-only accessor/,
              'cannot set read-only class attribute' );
    }

    {
        is( Child->ReadOnlyAttribute(), 30,
            q{Child class can extend parent's class attribute} );
    }

    {
        ok( ! HasClassAttribute->HasM(),
            'HasM() returns false before M is set' );

        HasClassAttribute->SetM(22);

        ok( HasClassAttribute->HasM(),
            'HasM() returns true after M is set' );
        is( HasClassAttribute->M(), 22,
            'M() returns 22' );

        HasClassAttribute->ClearM();

        ok( ! HasClassAttribute->HasM(),
            'HasM() returns false after M is cleared' );
    }

    {
        isa_ok( HasClassAttribute->Delegatee(), 'Delegatee',
                'has a Delegetee object' );
        is( HasClassAttribute->units(), 5,
            'units() delegates to Delegatee and returns 5' );
    }

    {
        my @ids = HasClassAttribute->IdsInMapping();
        is( scalar @ids, 0,
            'there are no keys in the mapping yet' );

        ok( ! HasClassAttribute->ExistsInMapping('a'),
            'key does not exist in mapping' );

        HasClassAttribute->SetMapping( a => 20 );

        ok( HasClassAttribute->ExistsInMapping('a'),
            'key does exist in mapping' );

        is( HasClassAttribute->GetMapping('a'), 20,
            'value for a in mapping is 20' );
    }
}


1;
