 package Business::Tax::VAT::Validation;
 ############################################################################
# IT Development software                                                    #
# European VAT number validator Version 0.09                                 #
# Copyright 2003 Nauwelaerts B  bpn#it-development%be                        #
# Created 06/08/2003            Last Modified 20/06/2006                     #
 ############################################################################
# COPYRIGHT NOTICE                                                           #
# Copyright 2003 Bernard Nauwelaerts  All Rights Reserved.                   #
#                                                                            #
# THIS SOFTWARE IS RELEASED UNDER THE GNU Public Licence                     #
# See COPYING for details                                                    #
#                                                                            #
#  This software is provided as is, WITHOUT ANY WARRANTY, without even the   #
#  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  #
#                                                                            #
 ############################################################################
# Revision history :                                                         #
# 0.09   20/06/2006; local_check method allows you to test VAT numbers       #
#                    without asking the EU database. Based on regexps.       #
# 0.08   20/06/2006; 9 and 10 digits transitional regexp for Belgium         #
#                    From 31/12/2007, only 10 digits will be valid           #
# 0.07   25/05/2006; Now we use "request" method not "simple request"        #
#                    in order to follow potential redirects                  #
# 0.06   25/05/2006; Changed $baseurl					     #
#                    (Thanks to Torsten Mueller for this update)	     #
# 0.05   19/01/2006; Adding support for proxy settings			     #
#                    (Thanks to Tom Kirkpatrick for this update)	     #
# 0.04   01/11/2004; Adding support for error "Member Service Unavailable"   #
# 0.03   01/11/2004; Adding 10 new members.                                  #
#                    (Thanks to Robert Alloway for this update)              #
# 0.02   29/09/2003; Fix alphanumeric VAT numbers rejection                  #
#                    (Thanks to Robert Alloway for the regexps)              #
# 0.01   06/08/2003; Initial release                                         #
#                                                                            #
 ############################################################################

BEGIN {
    $VERSION = "0.09";
    use strict;
    use HTTP::Request::Common qw(POST);
    use LWP::UserAgent;
}

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

=head1 PROPERTIES

=item B<member_states> Returns all member states 2-digit codes

=head1 METHODS

=over 4

=item B<new> Class constructor.

    $hvatn=Business::Tax::VAT::Validation->new();
    
    
    If your system is located behind a proxy :
    
    $hvatn=Business::Tax::VAT::Validation->new(-proxy => ['http', 'http://example.com:8001/']);
    
    
=cut

sub new {
    my $class   = shift;
    my %arg     = @_;
    my $self = {
        members  => 'AT|BE|CY|CZ|DE|DK|EE|EL|ES|FI|FR|GB|HU|IE|IT|LT|LU|LV|MT|NL|PL|PT|SE|SI|SK',
        #baseurl  => 'http://europa.eu.int/comm/taxation_customs/vies/cgi-bin/viesquer', # Obsolete since v0.06
	baseurl  => 'http://ec.europa.eu/taxation_customs/vies/cgi-bin/viesquer',
        error    =>    '',
        re       => {
            AT      =>  'U[0-9]{8}',
            BE      =>  '[0|1]?[0-9]{9}',
	    CY      =>  '[0-9]{8}[A-Za-z]',
	    CZ	    =>  '[0-9]{8,10}',
            DE      =>  '[0-9]{9}',
            DK      =>  '[0-9]{8}',
	    EE	    =>  '[0-9]{9}',
            EL      =>  '[0-9]{9}',
            ES      =>  '([A-Za-z][0-9]{8}|[A-Za-z][0-9]{7}[A-Za-z]|[0-9]{8}[A-Za-z])',
            FI      =>  '[0-9]{8}',
            FR      =>  '([0-9]{11}|[A-HJ-NP-Za-hj-np-z][0-9]{10}|[A-HJ-NP-Za-hj-np-z]{2}[0-9]{9}|[0-9][A-HJ-NP-Za-hj-np-z][0-9]{9})',
            GB      =>  '([0-9]{9}|[0-9]{12}|GD[0-9]{3}|HA[0-9]{3})',
	    HU      =>  '[0-8]{8}',
            IE      =>  '([0-9]{7}[A-Za-z]|[0-9][A-Za-z][0-9]{5}[A-Za-z])',
            IT      =>  '[0-9]{11}',
	    LT      =>  '([0-9]{9}|[0-9]{12})',
            LU      =>  '[0-9]{8}',
	    LV      =>  '[0-9]{11}',
	    MT	    =>  '[0-9]{8}',
            NL      =>  '[0-9]{9}B[0-9]{2}',
	    PL      =>  '[0-9]{10}',
            PT      =>  '[0-9]{9}',
            SE      =>  '[0-9]{10}01',
	    SI	    =>  '[0-9]{8}',
	    SK	    =>  '[0-9]{10}',
        },
	proxy => $arg{-proxy}
    };
    $self = bless $self, $class;
    $self;
}

sub member_states {
    my $self=shift;
    (keys %{$self->{re}})
}

=item B<check> - Checks if a VAT number exists into the VIES database
    
    $ok=$hvatn->check($VAT, [$member_state]);

You may either provide the VAT number under its complete form (e.g. BE-123456789, BE123456789 or BE 123 456 789)
or either specify VAT and MS (member state) individually.

Valid MS values are :

 AT, BE, CY, CZ, DE, DK, EE, EL, ES, FI, 
 FR, GB, HU, IE, IT, LU, LV, MT, NL, PL,
 PT, SE, SI, SK

=cut

sub check {
    my $self=shift;
    my $vatn=shift || return $self->_set_error('You must provide a VAT number');
    my $mscc=shift || '';
    ($vatn, $mscc)=$self->_is_valid_format($vatn, $mscc);
    if ($vatn) {
        my $ua = LWP::UserAgent->new;
	if (ref $self->{proxy} eq 'ARRAY') {
	    $ua->proxy(@{$self->{proxy}});
	} else {
	    $ua->env_proxy;
	}
        $ua->agent('Business::Tax::VAT::Validation/'.$Business::Tax::VAT::Validation::VERSION);
        my $req = POST $self->{baseurl},
        [
            'Lang'        => 'EN',
            'MS'          => $mscc ,
            'VAT'         => $vatn ,
            'ISO'         => $mscc ,
        ];
        return $mscc.'-'.$vatn if $self->_is_res_ok($ua->request($req)->as_string);
    }
    0;
}


=item B<local_check> - Checks if a VAT number format is valid
    
    $ok=$hvatn->local_check($VAT, [$member_state]);
    
    This method is based on regexps only and DOES NOT asks the VIES database

=cut

sub local_check {
    my $self=shift;
    my $vatn=shift || return $self->_set_error('You must provide a VAT number');
    my $mscc=shift || '';
    ($vatn, $mscc)=$self->_is_valid_format($vatn, $mscc);
    if ($vatn) {
        return 1
    } else {
        return 0
    }
}

=item B<get_last_error> - Return the last recorded error

    $hvatn->get_last_error();

Possible errors are :
    
- Unknown MS code : Internal checkup failed (Specified MS does not exists)
- Invalid VAT number format : Internal checkup failed (bad syntax)
- This VAT number doesn't exists in EU database : distant checkup
- This VAT number contains errors : distant checkup
- Time out connecting to the database : Temporary error when the connection to the database times out
- Member Sevice Unavailable: The EU database is unable to reach the requested member's database.
- Invalid response, please contact the author of this module. : This normally only happens if this software doesn't recognize any valid pattern into the response document: this generally means that the database interface has been modified.
  
=cut

sub get_last_error {
    shift->{error};
}


### PRIVATE FUNCTIONS ==========================================================
sub _is_valid_format {
    my $self=shift;
    my $vatn=shift;
    my $mscc=shift;
    my $null='';
    $vatn=~s/\-//g; $vatn=~s/\.//g; $vatn=~s/ //g;
    if ($vatn=~s/^($self->{members})/$null/e) {
        $mscc=$1;
    }
    return $self->_set_error("Unknown MS code") if $mscc!~m/^($self->{members})$/;
    my $re=$self->{re}{$mscc};
    return $self->_set_error("Invalid VAT number format") if $vatn!~m/^$re$/;
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
        } elsif (/Request time-out\. Please re-submit your request later/){
			return $self->_set_error("Time out connecting to the database")
        } elsif (/^\s*Member State service unavailable/) {
            return $self->_set_error("Member State service unavailable: Please re-submit your request later.")
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

Bernard Nauwelaerts <bpn#it-development%be>

=head1 LICENSE

GPL.  Enjoy !
See COPYING for further informations on the GPL.

=head1 Credits

  Thanks to Robert Alloway for providing us internal checkup regexp's for VAT numbers, and the patch adding 10 new members.
  Thanks to Tom Kirkpatrick for his proxy support suggestion.
  Thanks to Torsten Mueller to inform me about $baseurl modification.
  
=head1 Disclaimer

See I<http://ec.europa.eu/taxation_customs/vies/en/viesdisc.htm> to known the limitations of the EU validation service.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
1;
