#
# Byspam Mail parsing library
#
# $Id$
#

package Byspam::Parse;

use strict;

use Byspam::Common;
use Byspam::Encode;
use MIME::Base64;
use MIME::QuotedPrint;

my $cm = new Byspam::Common;
my $cv = new Byspam::Encode;

sub new {
	my $self = {};
	return bless $self;
}

# charset convert
#
sub setCharset {
	my $self = shift if ref ($_[0]);
	my $locale = $_[0];
	my %ret;

	$ret{"to"} = $main::charset;
	$ret{"to"} = "utf-8" if ( ! $ret{"to"} );
	$ret{"to"} = lc ($ret{"to"});
	$ret{"from"} = "";

	return %ret if ( $locale =~ m/[^0-9a-z-]/i );

	if ( $locale ) {
		$locale = lc ($locale);

		$locale = "cp949" if ( $locale =~ m/uhc|windows-949|ks_c_5601-1987/i );

		# if not euc-kr or utf-8, unset;
		if ( $ret{'to'} ne 'utf-8' ) {
			$locale = "" if ( $locale ne "utf-8" && $locale ne "euc-kr" && $locale ne "cp949" );
			$ret{"from"} = $locale if ( $locale && $locale ne $ret{"to"} && $locale ne "cp949" );
		} else {
			$ret{'from'} = $locale;
		}

	}

	return %ret;
}

# parse of mail header
#
sub getHeader {
	my $self = shift if ref ($_[0]);

	my $head = $_[0];
	my $encode;
	my $headReturn;
	my $line;
	my @heads = ();
	my %charset;

	# get whole header
	if ( $head ) {
		$head =~ s/\r?\n/\n/g;
		$head =~ s/(=\?[^?]*\?[BQ]\?[^?]+\?=)/\n$1\n/ig;
		@heads = split (/\r?\n/, $head);
	}

	foreach $line ( @heads ) {
		my @lines = ();

		if ( $line =~ m/=\?[^?]*\?[BQ]\?[^?]+\?=/i ) {
			$line =~ s/[\s]*=\?([^?]*)\?([BQ])\?([^?]+)\?=[\s]*/$1:$2:$3/ig;
			@lines = split (/:/, $line);

			# utf-8 problem
			%charset = setCharset ($lines[0]);
			$encode = ( $lines[1] =~ m/^b$/i ) ? "base64" : "qprint";
			$line   = ( $encode eq "base64" ) ? decode_base64 ($lines[2]) : decode_qp ($lines[3]);
			$line   = $cv->byconv ($line, $charset{"from"}, $charset{"to"}) if ( $charset{"from"} );
		}

		$headReturn .= $line;
	}

	if ( $headReturn ) {
		$headReturn =~ s//\n/ig;
		#$headReturn =~ s/\n//ig;
		$headReturn =~ s/\s[\s]+/ /ig;
		$headReturn =~ s/(Subject:[^\n]+)\n([^:]+)\n/$1$2\n/isg;

		return $headReturn;
	}

	return "";
}

# parse of each header field
sub parseHeader {
	my $self = shift if ref ($_[0]);

	my $head = $_[0];
	my $headReturn;
	my %charset;

	if ( $head && $head =~ m/=\?[^?]*\?[BQ]\?[^?]+\?=/i ) {
		my @heads = ();
		my @lines =();
		my $line;
		my $encode;

		$head =~ s/(=\?[^?]*\?[BQ]\?[^?]+\?=)/\n$1\n/ig;
		@heads = split (/\r?\n/, $head);

		foreach $line ( @heads ) {
			if ( $line !~ /=\?[^?]*\?([BQ])\?/i ) {
				next if ( $line =~ m/^[\s]*$/i );
			} else {
				$line =~ s/[\s]*=\?([^?]*)\?([BQ])\?([^?]+)\?=[\s]*/$1:$2:$3/ig;
				@lines = split (/:/, $line);

				# utf-8 problem
				%charset = setCharset ($lines[0]);
				$encode = ( $lines[1] =~ m/^b$/i ) ? "base64" : "qprint";
				$line   = ( $encode eq "base64" ) ? decode_base64 ($lines[2]) : decode_qp ($lines[2]);
				$line   = $cv->byconv ($line, $charset{"from"}, $charset{"to"}) if ( $charset{"from"} );
			}

			$headReturn .= " ".$line;
		}
	} else {
		%charset = setCharset ($main::charset_mail);
		$headReturn = $cv->byconv ($head, $charset{"from"}, $charset{"to"});
	}

	if ( $headReturn ) {
		$headReturn =~ s/[\s]+/ /ig;
		return $headReturn;
	}

	return "";
}


# get mail body plain of html type.
#
sub getBody {
	my $self = shift if ref ($_[0]);

	my $_mail = $_[0];

	my $bodyText = "";
	my $bodyReturn = "";
	my $bodyRegex = "";
	my $line = "";

	# get body
	$bodyText = $_mail->{_body};

	return "" if ( ! $_mail->{_body} );

	# get whole content type of mail
	my $ctChk = $_mail->header ("Content-Type");

	my $ct;
	my $bound = "";

	if( $ctChk ) {
		$ctChk = $cm->trim ($ctChk);
		$ctChk =~ s/\n[\s]*/ /sg;

		# get content type
		$ct = $ctChk;
		$ct =~ s/^([a-z]+\/[a-z]+)[\s]*;.+/$1/ig;

		$bound = $ctChk;
		$bound =~ s/.*boundary[\s]*=[\s]*"?([^";\s]+)"?.*/$1/ig;
	}

	BODY: {
		( $ct && $ct =~ /alternative/i ) and do {
			$bodyReturn = actAlternative ($bodyText, $bound);
			last BODY;
		};
		( $ct && $ct =~ /mixed|related/i ) and do {
			$bodyReturn = actMixed ($bodyText, $bound);
			last BODY;
		};
		$bodyReturn = actPlain ($bodyText, $_mail);
	}

	if ( $bodyReturn ) {
		$bodyReturn =~ s///g;
		return $bodyReturn;
	}

	return "";
}

sub actPlain {
	my $self = shift if ref ($_[0]);

	my ( $_body, $_mail ) = @_;
	my $encode;
	my %_c;
	my $_cset;

	$encode = $_mail->header ("Content-Transfer-Encoding"); 

	if ( $encode ) {
		$_body = ( $encode =~ m/base64/i ) ? decode_base64 ($_body) : decode_qp ($_body);
	}

	$_cset = $_mail->header ("Content-Type");
	$_cset =~ s/.*charset="?([^;"\s]+)"?;?/$1/isg;
	%_c = setCharset ($_cset);

	$_body = $cv->byconv ($_body, $_c{"from"}, $_c{"to"}) if ( $_c{"from"} );

	return $_body;
}

# parse mail body on multipard/alternative type
#
sub actAlternative {
	my $self = shift if ref ($_[0]);

	my ( $_body, $_bound ) = @_;

	my @Body = ();
	my $return;

	$_bound =~ s/([+*.])/\\$1/g;
    $_body =~ s!(Content-Type:\s*text/plain;)\s*(charset\s*=)!$1 $2!isg;

	@Body = split (/-+$_bound/, $_body);

	my $bodySize = @Body;
	my $i;
	my $isplain = -1;
	my $ishtml = -1;
	my $encode;

	my @cset_r;
    my $_cset = "";
	my %_c;

	for ( $i=0; $i<$bodySize; $i++ ) {
		next if ( $Body[$i] !~ m/Content-Type/i );

		if ( $Body[$i] =~ m!Content-Type:\s*text/plain(;\s*charset\s*=\s*"?([^\s";]+)"?)?!i ) {
			# if attach file, pass
			next if ( $Body[$i] =~ m!text/plain;(\s*charset="?[^;]+"?;)?\s*name=!i );
			$isplain = $i;
			$cset_r[$i] = $2;
			next;
		}

		if ( $Body[$i] =~ m!Content-Type:\s*text/html(;\s*charset\s*=\s*"?([^\s";]+)"?)?!i ) {
			# if attach file, pass
			next if ( $Body[$i] =~ m!text/html;(\s*charset="?[^;]+"?;)\s*name=!i );
			$ishtml = $i;
			$cset_r[$i] = $2;
			next;
		}
	}

	if ( $ishtml > -1 ) {
		$return = $Body[$ishtml];
		$_cset = $cset_r[$ishtml];
	} else {
		$return = $isplain > -1 ? $Body[$isplain] : $_body;
		$_cset = $isplain > -1 ? $cset_r[$isplain] : "";
	}

	ENCODE: {
		( $return =~ m/Encoding\s*:\s*base64/i ) and $encode = "base64", last ENCODE;
		( $return =~ m/Encoding\s*:\s*quoted-printable/i ) and $encode = "qprint", last ENCODE;
		$encode = "plain";
	}

	$_cset = $return;
	$_cset =~ s/.*Content-Type\s*:\s*[^;]+;\s*charset\s*=\s*"?([^\s";]+).*/$1/isg;

	$return =~ s/Content-Type\s*:\s*[^;]+;\s*charset\s*=\s*"?[^\s";]+"?;?//isg;
	$return =~ s/Content-[^\r\n]+\r?\n?//ig;

	if ( $return ) {
		$return = ( $encode eq "base64" ) ? decode_base64 ($return) : decode_qp ($return);
		$return = $cm->trim ($return);
	}

	%_c = setCharset ($_cset);
	$return = $cv->byconv ($return, $_c{"from"}, $_c{"to"}) if ( $_c{"from"} );

	return $return;
}

# parse mail body on multipard/mixed type
#
sub actMixed {
	my $self = shift if ref ($_[0]);

	my ( $_body, $_bound ) = @_;
	my $return;

	if( $_body !~ /multipart\/alternative/i ) {
		$return = actAlternative ($_body, $_bound);
	} else {
		$_body =~ s/--$_bound//ig;

		$_bound = $_body;
		$_bound =~ s/\s/ /ig;
		$_bound =~ s/.+\s*boundary="?([^\s"]+)"?\s*.+/$1/ig;
		$_bound =~ s/([+*])/\\$1/g;

		$_body =~ s/Content-Type\s*:\s*multipart.*|boundary=[^\s]+//img;
		$_body =~ s/(--$_bound)--.*/$1/isg;
		$return = actAlternative ($_body, $_bound);
	}

	return $return;
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
