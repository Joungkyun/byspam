#!@PERLPATH@ -W
#
# Perl regualr expression check utility in BySPAM
# JoungKyun Kim <http://www.oops.org>
# $Id: regexChk.pl,v 1.2 2004-11-27 19:06:48 oops Exp $
#
my $lcn;
my $lc;
my $USAGES;
my $targetA;
my $targetB;

$lcn = $ENV{"LANG"};
$lcn =~ s/^ko.*/ko/;
if ($lcn eq "ko") { $lc = 1; }

if ( $#ARGV < 1 ) {
  if($lc) {
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

if($string =~ /$pattern/igo) {
  if($lc) { print "사용할 수 있는 표현식 입니다.\n"; }
  else { print "This pattern is right\n" }
} else {
  if($lc) { print "표현식에 문제가 있습니다.\n"; }
  else { print "This pattern is wrong\n"; }
}
