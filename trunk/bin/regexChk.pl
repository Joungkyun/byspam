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
    $USAGES  = "����";
    $targetA = "üũ �� ���ڿ�";
    $targetB = "üũ �� ����ǥ���� ����";
    $WN      = "A �� B �� �� ���� ����ǥ�� ���ξ� �Ѵ�."
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
  if ($charset eq "EUC-KR" ) { print "����� �� �ִ� ǥ���� �Դϴ�.\n"; }
  else { print "This pattern is right\n" }
} else {
  if ( $charset eq "EUC-KR" ) { print "ǥ������ �־��� ���ڿ��� ��ġ�� ���� �ʽ��ϴ�.\n"; }
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