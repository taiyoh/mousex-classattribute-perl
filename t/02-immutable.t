use strict;
use warnings;

use lib 't/lib';

use SharedTests;

HasClassAttribute->meta()->make_immutable();
Child->meta()->make_immutable();

SharedTests::run_tests();
