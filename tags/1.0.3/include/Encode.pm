#
# Byspam EUC-KR UTF-8 convert module
#
# $Id$
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

	return $string if ( ! $from || ! $to || $from eq $to );

	$buf = $string;
	eval ("Encode::from_to (\$buf, uc ('$from'), uc ('$to'));");
	$buf = $string if ( $@ );

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
