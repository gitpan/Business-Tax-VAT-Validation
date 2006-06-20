#!/usr/bin/env perl -w
use strict;
use Test;
BEGIN { plan tests => 2 }

use Business::Tax::VAT::Validation;

my $hvat=Business::Tax::VAT::Validation->new();
if (ref $hvat){
    ok(1);
} else {
    ok(0);
}
my $res=$hvat->local_check('BE-0774257760');
if ($res){
    ok(1);
} else {
    ok(0);
}
exit;
__END__