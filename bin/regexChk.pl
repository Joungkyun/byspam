#!/usr/bin/perl -W
#
# Perl regualr expression check utility in BySPAM
# JoungKyun Kim <http://www.oops.org>
# $Id: regexChk.pl,v 1.3 2004-11-28 11:50:11 oops Exp $
#

use strict;

my $charset;
my $USAGES;
my $targetA;
my $targetB;
my $WN;

$charset = $ENV{"LANG"};
CHARSET: {
	( $charset =~ m/^ko/i ) and $charset = "EUC-KR", last CHARSET;
	( $charset =~ m/^utf/i ) and $charset = "UTF-8", last CHARSET;
	$charset = "";
}

if ( $#ARGV != 1 ) {
  if( $charset eq "EUC-KR" ) {
    $USAGES  = "사용법";
    $targetA = "체크 할 문자열";
    $targetB = "체크 할 정규표현식 패턴";
    $WN      = "A 와 B 는 꼭 작음 따옴표로 감싸야 한다."
  } else {
    $USAGES  = "USAGE";
    $targetA = "Check string";
    $targetB = "Check regex pattern";
    $WN      = "A and B is must quoted single quote"
  }

  print "$USAGES : regexChk.pl 'A' 'B'\n";
  print "          A => $targetA\n";
  print "          B => $targetB\n";
  print "          $WN\n";
  exit;
}

my $string;
my $pattern;

$string = "$ARGV[0]";
$pattern = "$ARGV[1]";

if( $string =~ /$pattern/ig ) {
  if ($charset eq "EUC-KR" ) { print "사용할 수 있는 표현식 입니다.\n"; }
  else { print "This pattern is right\n" }
} else {
  if ( $charset eq "EUC-KR" ) { print "표현식이 주어진 문자열과 매치가 되지 않습니다.\n"; }
  else { print "This expression is not match given string\n"; }
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
