use inc::Module::Install;
name 'MouseX-ClassAttribute';
all_from 'lib/MouseX/ClassAttribute.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
