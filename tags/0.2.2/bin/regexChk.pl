#!@PERLPATH@ -W
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

if($string =~ /$pattern/igo) {
  if($lc) { print "����� �� �ִ� ǥ���� �Դϴ�.\n"; }
  else { print "This pattern is right\n" }
} else {
  if($lc) { print "ǥ���Ŀ� ������ �ֽ��ϴ�.\n"; }
  else { print "This pattern is wrong\n"; }
}
