#!/usr/bin/perl
 ############################################################################
# IT Development software                                                    #
# European VAT number validator                                              #
# command line interface           Version 0.01                              #
# Copyright 2003 Nauwelaerts B     bpn#it-development%be                     #
# Created 06/08/2003               Last Modified 06/08/2003                  #
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
#                                                                            #
# 0.01   06/08/2003;                                                         #
#                                                                            #
 ############################################################################
  use Business::Tax::VAT::Validation;
  
  my $hvatn=Business::Tax::VAT::Validation->new();
  
  # Check number
  if (my $n=$hvatn->check($ARGV[0])) {
        print $n.": OK\n";
  } else {
        print $ARGV[0].': '.$hvatn->get_last_error."\n";
  }