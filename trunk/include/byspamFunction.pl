# include function of spam fileter
#
# get filtering file value
#
sub filterText {
  my $list;
  if ( -f "$_[0]" ) {
    open(fileHandle,$_[0]);
    foreach(<fileHandle>) {
      if(! /^#/ig && ! /^[ \t]*$/g ) {
        chomp($aLine = $_);
        chomp($list = !$list ? "$aLine" : $list."|$aLine");
      }
    }
    close(fileHandle);
  }
  if($list) { return $list; }
}


# get context of file
#
sub getContext {
  my @list = ();
  my $i = 0;
  if ( -f "$_[0]" ) {
    open(fileHandle,$_[0]);
    foreach(<fileHandle>) {
      $list[$i] = $_;
      $i++;
    }
  }
  return @list;
}


# parse of mail header
#
sub getHeader {
  my $head;
  my $headReturn;

  # get whole header
  foreach $line (@{$_[0]->header()}){ $head .= $line; }

  my @heads = ();
  $head =~ s/\r?\n/\n/g;
  $head =~ s/(=\?[^?]+\?[BQ]\?[^?]+\?=)/\n$1\n/g;
  @heads = split(/\r?\n/,$head);

  my @lines =();
  foreach $line (@heads) {
    if ($line =~ /=\?[^?]+\?[BQ]\?[^?]+\?=/i) {
      $line =~ s/[\s]*=\?[^?]+\?([BQ])\?([^?]+)\?=[\s]*/$1:$2/ig;
      @lines = split(/:/,$line);
      if($lines[0] =~ /^b$/i) { $encode = "base64"; }
      else { $encode = "qprint"; }
      if($encode eq "base64") { $line = decode_base64($lines[1]); }
      else { $line = decode_qp($lines[1]); }
    }
    $headReturn .= $line;
  }

  if($headReturn) {
    $headReturn =~ s//\n/ig;
    $headReturn =~ s/\n//ig;
    $headReturn =~ s/\s[\s]+/ /ig;

    return $headReturn;
  } else { return "null"; }
}

# parse of each header field
sub parseHeader {
  my $head;
  my $headReturn;
  my $encode;
  $head = $_[0];

  my @heads = ();
  if($head && $head =~ /=\?[^?]+\?[BQ]\?[^?]+\?=/i) {
    $head =~ s/(=\?[^?]+\?[BQ]\?[^?]+\?=)/\n$1\n/ig;
    @heads = split(/\r?\n/,$head);

    my @lines =();
    LINE: foreach $line (@heads) {
      if($line !~ /=\?[^?]+\?([BQ])\?/i) {
        if($line =~ /^[\s]*$/i) { next LINE; }
      } else {
        $line =~ s/[\s]*=\?[^?]+\?([BQ])\?([^?]+)\?=[\s]*/$1:$2/ig;
        @lines = split(/:/,$line);
        if($lines[0] =~ /^b$/i) { $encode = "base64"; }
        else { $encode = "qprint"; }

        if($encode eq "base64") { $line = decode_base64($lines[1]); }
        else { $line = decode_qp($lines[1]); }
      }
      $headReturn .= " ".$line;
    }
  } else { $headReturn = $head; }

  if ( $headReturn ) {
    $headReturn =~ s/[\s]+/ /ig;
    return $headReturn;
  } else { return "null"; }
}


# get mail body plain of html type.
#
sub getBody {
  my $ct;
  my $bound;
  my $bodyText;
  my $bodyReturn;
  my $bodyRegex;

  # get mail body
  foreach $line (@{$_[0]->body()}) { $bodyText .= $line; }

  # previous spam check of body header
  if ( -f "$filterDir/filter-extra" ) {
    $bodyRegex = filterText("$filterDir/filter-extra");
  }

  if ( ! $_[1] && $bodyRegex && $bodyText =~ /$bodyRegex/i ) {
    $body_spam = 1;
    return $bodyText;
  } else {
    # get whole content type of mail
    my $ctChk = $_[0]->get("Content-Type:");
    if($ctChk) {
      chomp($ctChk);
      $ctChk =~ s/\s/ /g;

      # get content type
      $ct = $ctChk;
      $ct =~ s/^([a-z]+\/[a-z]+)[\s]*;.+/$1/ig;

      $bound = $ctChk;
      $bound =~ s/.*boundary[\s]*=[\s]*"?([^";\s]+)"?.*/$1/ig;
      $bound =~ s/!byspamEnter!//g;
    }

    if($ct && $ct =~ /multipart\/alternative/i ) {
      $bodyReturn = actAlternative($bodyText,$bound);
    } elsif($ct && $ct =~ /multipart\/(mixed|related)/i ) {
      $bodyReturn = actMixed($bodyText,$bound);
    } else {
      $bodyReturn = actPlain($bodyText,$_[0]);
    }

    $bodyReturn =~ s///g;

    if( $bodyReturn ) { return $bodyReturn; }
    else { return "null"; }
  }
}

sub actPlain {
  my $encode;
  $encode = $_[1]->get("Content-Transfer-Encoding"); 

  if ($encode) {
    if ( $encode =~ /base64/i ) { $_[0] = decode_base64($_[0]); }
    elsif ( $encode =~ /quoted/i ) { $_[0] = decode_qp($_[0]); }
  }

  $_[0] =~ s/!byspamEnter!/\n/g;
  return $_[0];
}

# parse mail body on multipard/alternative type
#
sub actAlternative {
  my @Body = ();
  my $return;
  my $bounds = $_[1];
  $bounds =~ s/([+*])/\\$1/g;
  @Body = split(/-+$bounds/,$_[0]);

  my $bodySize = @Body;
  my $i;
  my $isplain = "null";
  my $ishtml = "null";
  LINE: for ($i=0;$i<$bodySize;$i++) {
    #if ($Body[$i] =~ /$bounds/i) { $Body[$i] =~ s/--$bounds//g; }
    if ($Body[$i] =~ /Content-Type:[\s]*text\/plain/i) { $isplain = $i; }
    elsif ($Body[$i] =~ /Content-Type:[\s]*text\/html/i) { $ishtml = $i; }
    elsif ($Body[$i] !~ /Content-Type/i) { next LINE; }
    else { last LINE; }
  }

  if ($ishtml ne "null") {
    $return = $Body[$ishtml];
  } elsif ($isplain ne "null") {
    $return = $Body[$isplain];
  }

  $return =~ s/!byspamEnter!/\n/g;

  my $encode;
  if ($return =~ /Encoding\s*:\s*base64/i) { $encode = "base64"; }
  elsif ($return =~ /Encoding\s*:\s*quoted-printable/i) { $encode = "qprint"; }
  else { $encode = "plain"; }

  $return =~ s/Content-Type\s*:\s*[^;]+;\n\s*charset\s*=\s*"?[^\s"]+"?//ig;
  $return =~ s/Content-[^\r\n]+\r?\n?//ig;

  if($return) {
    if ($encode eq "base64") { 
      $return = decode_base64($return);
    } elsif ($encode eq "qprint") { $return = decode_qp($return); }
  }

  if ($return) {
    chomp($return);
    return $return;
  } else { return "null"; }
}

# parse mail body on multipard/mixed type
#
sub actMixed {
  my $return;

  if($_[0] !~ /multipart\/alternative/i) { $return = actAlternative($_[0],$_[1]); }
  else {
    $_[0] =~ s/!byspamEnter!/\n/g;
    $_[0] =~ s/--$_[1]//ig;

    my $bound = $_[0];
    $bound =~ s/\s/ /ig;
    $bound =~ s/.+\s*boundary="?([^\s"]+)"?\s*.+/$1/ig;
    $bound =~ s/([+*])/\\$1/g;

    $_[0] =~ s/Content-Type\s*:\s*multipart|boundary=[^\s]+//ig;
    $return = actAlternative($_[0],$bound);
  }

  if($return) {
    return $return;
  } else { return "null"; }
}

# print help message and save directory
#
sub printHelp {
  if ( $_[0] > -1 ) {
    foreach($_[1]) {
      if( $_ eq "-h" || $_ eq "--help" ) {

        my $lc;
        my $lcn;
        $lcn = $ENV{"LANG"};
        if ($lcn) { $lcn =~ s/^ko.*/ko/ig; }
        if ($lcn && $lcn eq "ko") { $lc = 1; }

        my @helps = ();
        if($lc) {
          $USAGES = "사용법";
          @helps = (
                    "현재 메세지를 출력",
                    "인자로 넘긴 메일형식의 절대경로 파일을 체크 [ 디버그 모드 ]",
                    "메일 형식을 파이프로 넘기는 형식",
                   );
        } else {
          $USAGES = "USAGE";
          @helps = (
                     "print this message",
                     "debug mode with file(absolte path) of mail form",
                     "put mail form with pipe",
                     "print out save message"
                   );
        }

        print "$USAGES : \n";
        print "    byspamFilter [ -h --help ]\n";
        print "          => $helps[0]\n";
        print "    byspamFilter -d mail_form_file_pull_path \n";
        print "          => $helps[1]\n";
        print "    cat mail_form_file | byspamFilter \n";
        print "          => $helps[2]\n";
        exit;
      }
    }
  }
}

# check of no content
sub noContentCheck {
  if ($_[0] eq "") { return 1; }

  my $content;
  $content = $_[0];
  $content =~ s/[\s]//ig;
  $content =~ s/<html>.*<\/head>//ig;
  $content =~ s/<[^>]*>//ig;

  if ($content eq "") { return 1; }
}
