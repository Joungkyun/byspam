#!@PERLPATH@ -W
#
# Mail Parse Utility supported by BySPAM
# JoungKyun Kim <http://www.oops.org>
# $Id: plain.pl,v 1.4 2004-11-29 06:25:27 oops Exp $
#
use lib '@includedir@';
my $conf = "@confdir@/byspam.conf";

use strict;

use Byspam::Getopt;
use Byspam::Common;
use Byspam::Parse;
use Byspam::Mail;

# declaration global variable on configuration file
use vars qw ($version  $level $allows $ignore $filterIframe $filterTag);
use vars qw ($nobody $noheader $charset @basics $trashPeriod);
use vars qw ($binDir  $confdir $filterDir $includeDir $perlpath);

my $cm;
my $o;
my $ov;

# options variable
my $opt;
my %_opt;
my $_file;

# get argument on shell
my $_argc    = $#ARGV; 
my @_argv    = @ARGV;

# create reference Common
$cm = new Byspam::Common;

# get configuration file
if ( ! -f "$conf" ) {
	$cm->printError (
			"\n" .
			"    Configuration file missing.\n" .
			"    Check \"$conf\" file\n" .
			"\n"
	);
	exit 1;
}

require $conf;

if ( ! $charset ) {
	$charset = $ENV{"LANG"};
	CHARSET: {
		( $charset =~ m/^ko/i ) and $charset = "EUC-KR", last CHARSET;
		( $charset =~ m/^utf/i ) and $charset = "UTF-8", last CHARSET;
		$charset = "";
	}
}

# create reference Getopt
$o = new Byspam::Getopt;
$ov = $o->{_var};

# match long option whit short option
$ov->{longopt} = {
	'body'        => 'B',
	'header'      => 'H',
	'help'        => 'h'
};

$_opt{body}   = 0;
$_opt{header} = 0;

while ( 1 ) {
	$opt = $o->getopt ("BHvh", $_argc + 1, @_argv);
	last if ( ! $opt );

	SWITCH: {
		( $opt eq "B" ) and do {
			$_opt{body} = 1;
			last SWITCH;
		};
		( $opt eq "H" ) and do {
			$_opt{header} = 1;
			last SWITCH;
		};

		Help ();
	}
}

Help () if ( $ov->{getopt_err} or $ov->{optcno} != 1 );

$_file = $ov->{optcmd}->[0];
if ( ! $_opt{body} && ! $_opt{header} ) {
	$_opt{body} = 1;
	$_opt{header} = 1;
}


my $ps;
my $mail;
my @mailText = ();

@mailText = $cm->getContext_rr ($_file);

$mail = Byspam::Mail->new (\@mailText);
$ps = Byspam::Parse->new ();

system "clear";
print "[ Result of Decoding $_file ]\n\n";

if ( $_opt{header} ) {
	print "####  Mail Header  #############################################\n";
	print "\n";
	print $ps->getHeader ($mail->{_header}) . "\n\n";
}

if ( $_opt{body} ) {
	print "#####  Mail Body   #############################################\n";
	print "\n";
	print $ps->getBody ($mail) . "\n\n";
}


sub Help {
	my @helps = ();
	my $USAGES;

	if ( $main::charset eq "EUC-KR" ) {
		$USAGES = "사용법";
		@helps = (
					"현재 메세지를 출력",
					"지정된 파일의 메일 본문만 디코딩 하여 출력",
					"지정된 파일의 메일 헤더만 디코딩 하여 출력"
		);
	} else {
		$USAGES = "USAGE";
		@helps = (
					"print this message",
					"print out decoded mail body in filename",
					"print out decoded mail header in filename"
		);
	}

	$cm->printError (
			"$USAGES : $0 -[hHB] filename\n" .
			"          -h --help   => $helps[0]\n" .
			"          -B --body   => $helps[1]\n" .
			"          -H --header => $helps[2]\n"
	);
	exit 1;
}

exit 0;

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noet sw=4 ts=4 fdm=marker
# vim<600: noet sw=4 ts=4
#
