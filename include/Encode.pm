#
# Byspam EUC-KR UTF-8 convert module
#
# $Id: Encode.pm,v 1.2 2009-12-02 07:30:10 oops Exp $
#

package Byspam::Encode;

use strict;
my $_module = "";

if ( $] >= 5.007003 ) {
	$_module = "Encode";
} else {
	$_module = "Encode::compat";
}

eval ("use $_module");
die "$_module load error\n" if ( $@ );

sub new {
	my $self = {};
	return bless $self;
}

sub byconv {
	my $self = shift if ref ($_[0]);
	my ($string, $from, $to) = @_;
	my $buf;

	return $string if ( $from eq $to );

	Encode::from_to ($buf, $from, $to);

	return $buf if ( $buf );
	return $string;
}

1;

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noet sw=4 ts=4 fdm=marker
# vim<600: noet sw=4 ts=4
#
