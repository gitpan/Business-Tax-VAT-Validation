#!/usr/bin/env perl -w
use strict;
use Test;
BEGIN { plan tests => 1 }

use Business::Tax::VAT::Validation;

my $hvat=Business::Tax::VAT::Validation->new();
if (ref $hvat){
    ok(1);
} else {
    ok(0);
}

exit;
__END__