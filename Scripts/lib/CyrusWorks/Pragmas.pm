package CyrusWorks::Pragmas;
use 5.20.0;
use strict;
use warnings;
require feature;

sub import {
  strict->import();
  warnings->import();
  feature->import($_) for ( qw{ postderef signatures } );
  warnings->unimport($_) for ( qw{ experimental::postderef experimental::signatures } );
}

1;
