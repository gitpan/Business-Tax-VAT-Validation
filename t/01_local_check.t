#!/usr/bin/env perl -w
use strict;
use Test;

my %local_checks = (
    AT      =>  ['U12345678'],
    BE      =>  ['123456789', '0123456789'],
    BG      =>  ['123456789', '1234567890'],
    CY      =>  ['12345678A'],
    CZ	    =>  ['12345678', '123456789', '1234567890'],
    DE      =>  ['123456789'],
    DK      =>  ['12 45 78 90'],
    EE	    =>  ['123456789'],
    EL      =>  ['123456789'],
    ES      =>  ['123456789', 'A2345678B'],
    FI      =>  ['12345678'],
    FR      =>  ['12 456789012', 'A2 456789012', '1B 456789012', 'AB 456789012'],
    GB      =>  ['123 5678 01', '123 5678 12 234','GD345', 'HA123'],
    HU      =>  ['12345678'],
    IE      =>  ['1234567A', '1B34567C', '1+34567C', '1*34567C'],
    IT      =>  ['12345678901'],
    LT      =>  ['123456789', '123456789012'],
    LU      =>  ['12345678'],
    LV      =>  ['12345678901'],
    MT	    =>  ['12345678'],
    NL      =>  ['123456789B12'],
    PL      =>  ['1234567890'],
    PT      =>  ['123456789'],
    RO      =>  ['12', '123', '1234', '12345', '123456', '1234567', '12345678', '123456789', '1234567890'],
    SE      =>  ['123456789012'],
    SI	    =>  ['12345678'],
    SK	    =>  ['1234567890']
);

use Business::Tax::VAT::Validation;

my $tests = 0;

for my $ms (keys %local_checks) {
    $tests+= $#{$local_checks{$ms}} + 1
}

plan tests => $tests;

my $hvat=Business::Tax::VAT::Validation->new();
for my $ms (keys %local_checks) {
    for my $t (@{$local_checks{$ms}}) {
        my $res=$hvat->local_check($ms.$t);
        if ($res){
            ok(1);
        } else {
            warn("Local check for $ms$t failed");
        }        
    }
}
exit;
__END__
