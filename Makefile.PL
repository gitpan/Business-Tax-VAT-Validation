use 5.005;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Business::Tax::VAT::Validation',
    'VERSION_FROM'	=> 'lib/Business/Tax/VAT/Validation.pm', # finds $VERSION
    'PREREQ_PM'		=>  {
				HTTP::Request::Common => 1.0,
				LWP::UserAgent	      => 1.0,
                            }, 
    ABSTRACT_FROM    => 'lib/Business/Tax/VAT/Validation.pm',
	# Changed in 0.22
    AUTHOR           => 'Bernard Nauwelaerts <bpgn@cpan.org>',
	# Added in 0.22
	LICENSE          => 'GPL_3',
);
