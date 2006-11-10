#!/usr/bin/perl

use strict;
use CGI qw/:standard/;
use ITDev::Common;
use Business::Tax::VAT::Validation;

my $resultsfile='/isp/itdev/www/software/downloads.html';
my $title='A simple VAT checkup example';
    
my $res='';
    
if (param()) {
    my $vat=join("-",param('MS'),param('VAT'));
    $res.= h2("Results").$vat.': ';
    my $hvatn=Business::Tax::VAT::Validation->new();
    if ($hvatn->check($vat)) {
        $res.= 'Exists in database';
    } else {
        $res.= $hvatn->get_last_error;
    }
}

    
$res.= start_form.h2("Query")."VAT Number".p;
$res.= popup_menu(-name=>'MS', -values=>['AT','BE','DE','DK','EL','ES','FI','FR','GB','IE','IT','LU','NL','PT','SE']);
$res.= textfield('VAT').submit.end_form;
$res.= h2("Disclaimer"). "This interface is provided for demonstration purposes only, WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.".
       p.
       'See also this disclaimer: <a href="http://europa.eu.int/comm/taxation_customs/vies/en/viesdisc.htm">http://europa.eu.int/comm/taxation_customs/vies/en/viesdisc.htm</a>';

&parse_html($resultsfile, $title, $res, '', ''); 

exit;

sub parse_html {
    my($file)   =$_[0];			# HTML 2B parsed
    my($title)  =$_[1];			# Box output type
    my($result) =$_[2];			# Box output type
    my($head)   =$_[3];			# Box output type
    my($jscript)=$_[4];			# Box output type
    $title='Title' if !$title;
    $result='No Result' if !$result;
    $head='' if !$head;
    
    if ($jscript){
        $jscript='<script type="text/javascript">'."\n".$jscript.'   </script>';
    } else { $jscript='' }
    print "Content-Type: text/html\n\n";
  if (!-e $file) {print "$result"; exit;}
  open (TEMP, $file) or print "$result $file";
  	my $template = join ('', <TEMP>);
  close (TEMP);
  $template =~ s#<!-- TITLE -->#$title#sg if $title;
  $template =~ s#<!-- HEADER -->#$head#sg if $head;
  $template =~ s#<!-- RESULTS -->#$result#sg if $result;
  $template =~ s#<!-- JScript -->#$jscript#s if $jscript;
  #$template =~ s#<!-- Menu1 -->#$menu1#sg;
  #$template =~ s#<!--PageMarker-->#$PageMarker#sg;
  print $template;
  exit;
}