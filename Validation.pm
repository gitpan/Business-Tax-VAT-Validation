package Business::Tax::VAT::Validation;

use vars qw/$VERSION/;
$VERSION = "0.01";

=head1 NAME

Business::Tax::VAT::Validation - A class for european VAT numbers validation.

=head1 SYNOPSIS

  use Business::Tax::VAT::Validation;
  
  my $hvatn=Business::Tax::VAT::Validation->new();
  
  # Check number
  if ($hvatn->check($VAT, [$member_state])){
        print "OK\n";
  } else {
        print $hvatn->get_last_error;
  }
  
=head1 DESCRIPTION

This class provides you a easy api to check validity of european VAT numbers (if the provided number exists).

It asks the EU database for this. 

=cut

use strict;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use CGI::Cookie;



=head1 METHODS

=over 4

=item B<new> Class constructor.

    $hvatn=Business::Tax::VAT::Validation->new();

=cut

sub new {
    my $class   = shift;
    my $self = {
        members  => 'AT|BE|DE|DK|EL|ES|FI|FR|GB|IE|IT|LU|NL|PT|SE',
        baseurl  => 'http://europa.eu.int/comm/taxation_customs/vies/cgi-bin/viesquer',
        error    =>    '',
    };
    $self = bless $self, $class;
    $self;
}

=item B<check> - Checks if a client have access to this document
    
    $ok=$hvatn->check($VAT, [$member_state]);

You may either provide the VAT number under his complete form (e.g. BE-123456789, BE123456789 or BE 123 456 789)
or specify VAT and MS (member state) individually.

Valid MS values are :

 AT, BE, DE, DK, EL, ES, FI, FR, GB, IE, IT, LU, NL, PT, SE

=cut

sub check {
    my $self=shift;
    my $vatn=shift || return $self->_set_error('You must provide a VAT number');
    my $mscc=shift || '';
    ($vatn, $mscc)=$self->_is_valid_format($vatn, $mscc);
    if ($vatn) {
        my $ua = LWP::UserAgent->new;
        $ua->agent('Business::Tax::VAT::Validation/'.$VERSION);
        my $req = POST $self->{baseurl},
        [
            'Lang'        => 'EN',
            'MS'          => $mscc ,
            'VAT'         => $vatn ,
            'ISO'         => $mscc ,
        ];
        return $mscc.'-'.$vatn if $self->_is_res_ok($ua->simple_request($req)->as_string);
    }
    0;
}

=item B<get_last_error> - Returns last recorded error

    $hvatn->get_last_error();

Possible errors are :
    
- Invalid VAT number (1) : Internal checkup failed (formal)
- Invalid MS code (1) : Internal checkup failed
- This VAT number doesn't exists in EU database : distant checkup
- This VAT number contains errors : distant checkup
- Invalid response, please contact the author of this module. : This only happens if this software doesn't recognize any valid pattern into the response document: this generally means that the database interface has been modified.
  
=cut

sub get_last_error {
    shift->{error};
}


### PRIVATE FUNCTIONS ==========================================================
sub _is_valid_format {
    my $self=shift;
    my $vatn=shift;
    my $mscc=shift;
    $vatn=~s/\-//g; $vatn=~s/\.//g; $vatn=~s/ //g;
    if ($vatn=~s/($self->{members})//e) {
        $mscc=$1;
    }
    return $self->_set_error("Invalid VAT number (1)") if $vatn!~m/^\d+$/;
    return $self->_set_error("Invalid MS code (1)") if $mscc!~m/^($self->{members})$/;
    ($vatn, $mscc);
}
sub _is_res_ok {
    my $self=shift;
    my $res=shift;
    $res=~s/[\r\n]//; $res=~s/>/>\n/;
    foreach (split(/\n/, $res)) {
        next unless $_; 
        if (/^\s*No\, invalid VAT number$/) {
            return $self->_set_error("This VAT number doesn't exists in EU database.")
        } elsif (/^\s*Error\: (.*)$/) {
            return $self->_set_error("This VAT number contains errors: ".$1)
        }
        return 1 if /^\s*Yes\, valid VAT number$/;
    }
    $self->_set_error("Invalid response, please contact the author of this module.".$res)
}
sub _set_error {
    my $self=shift;
    $self->{error}=shift;
    0;
}

=head1 Other documentation

Jetez un oeil sur I<http://www.it-development.be/software/PERL/Business-Tax-VAT-Validation/> pour la documentation en français.


=head1 Feedback

If you find this module useful, or have any comments, suggestions or improvements, please let me know.

=head1 AUTHOR

Bernard Nauwelaerts <bpn@it-development.be>

=head1 LICENSE

GPL.  Enjoy !
See COPYING for further informations on the GPL.

=head1 Disclaimer

See I<http://europa.eu.int/comm/taxation_customs/vies/en/viesdisc.htm> to known the limitations of the EU service.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
1;
