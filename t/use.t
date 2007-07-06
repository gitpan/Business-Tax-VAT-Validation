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
my $res=$hvat->check('BE-0774257760');
if ($res){
    ok(1);
} else {
    warn $hvat->get_last_error_code.' '.$hvat->get_last_error;
}
exit;
__END__
