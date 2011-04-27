#!@PERLPATH@ -w
use Mail::Internet;
use Mail::Header;
use MIME::Base64;
use MIME::QuotedPrint;

local $includeDir;

# get config file
$conf = "@confdir@/byspam.conf";
if ( -f "$conf" ) { do "$conf"; }

# get sub function
do "$includeDir/byspamFunction.pl";

if($#ARGV < 0) {
  Help();
} 

my $paras;
my @para = ();
foreach (@ARGV) { $paras .= " ".$_; }
if ($paras !~ /-(h|f)/) { Help(); }
@para = split(/ -/,$paras);

my $file;
my $printBody;
my $printHead;
LINE: foreach (@para) {
  if($_ !~ /^[\s]*$/i) {
    if ($_ =~ /^-?h/) { Help(); }
    if ($_ =~ /^B/) { $printBody = 1; next LINE; }
    if ($_ =~ /^H/) { $printHead = 1; next LINE; }
    if ($_ =~ /^f/) {
      $file = $_;
      $file =~ s/^f[\s]+//go;
      if( ! -f $file ) { print "Error: $file not found!\n"; exit; }
      next LINE;
    }
  }
}

if ($paras !~ /-(B|H)/) { $printBody = $printHead = 1; }

my $mail;
my @mailText = ();
@mailText = getContext($file);

$mail = Mail::Internet->new(\@mailText);

if($printHead || $printBody) {
  system "clear";
  print "[ Result of Decoding $file ]\n\n";
}

if($printHead) {
  $header = getHeader($mail);
  print "#####  Mail Header  #############################################\n";
  print "\n";
  print "$header\n\n";
}

if($printBody) {
  $body = getBody($mail);
  print "#####   Mail Body   #############################################\n";
  print "\n";
  print "$body\n";
}

sub Help {
  my $lc;
  my $lcn; 
  $lcn = $ENV{"LANG"};
  if ($lcn) { $lcn =~ s/^ko.*/ko/igo; }
  if ($lcn && $lcn eq "ko") { $lc = 1; }

  my @helps = ();
  my $USAGES;
  if ($lc) {
    $USAGES = "����";
    @helps = (
              "���� �޼����� ���",
              "������ ������ ����� ������ ���ڵ��Ͽ� ���",
              "���� ������ ���ڵ� �Ͽ� ���",
              "���� ����� ���ڵ� �Ͽ� ���"
             );
  } else {
    $USAGES = "USAGE";
    @helps = (
               "print this message",
               "print out decoded header and body in filename",
               "print out decoded mail body in filename",
               "print out decoded mail header in filename"
             );
  }

  print "$USAGES : $0 -[hHB] -f filename\n";
  print "  -h --help   => $helps[0]\n";
  print "  -f filename => $helps[1]\n";
  print "  -B          => $helps[2]\n";
  print "  -H          => $helps[3]\n";
  exit 1;
}
