#!@PERLPATH@ -W
#
# Mail Parse Utility supported by BySPAM
# JoungKyun Kim <http://www.oops.org>
# $Id: plain.pl,v 1.2 2004-11-27 19:06:48 oops Exp $
#
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
    $USAGES = "사용법";
    @helps = (
              "현재 메세지를 출력",
              "지정한 메일의 헤더와 본문을 디코딩하여 출력",
              "메일 본문을 디코딩 하여 출력",
              "메일 헤더를 디코딩 하여 출력"
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
