#
# Perl - C style getopt library include long option functon
#
# scripted by JoungKyun Kim <http://oops.org>
#
# $Id: Getopt.pm,v 1.3 2009-12-02 07:34:53 oops Exp $
#

package Byspam::Getopt;
use strict;

sub new {
	my $self = {};

    $self->{_var}->{gno} = 0;
    $self->{_var}->{optcno} = 0;
    $self->{_var}->{optarg} = undef;
    $self->{_var}->{optcmd} = [];
    $self->{_var}->{longopt} = {};
    $self->{_var}->{getopt_err} = 0;

	return bless $self;
}

# getopt perl library
#
sub getopt {
	my $self = shift if ref ($_[0]);
	my ($_optstr, $_no, @_ary) = @_;

	my $opt;
    my $_v = $self->{_var};

    $_v->{getopt_err} = 0;

	$_v->{gno} = 0 if ( $_v->{gno} < 0 );
	$_v->{optcno} = 0 if ( $_v->{optcno} < 0 );

	LOOP1: while ( 1 ) {
		return "" if ( $_v->{gno} == $_no );

		# case by long option
		if ( $_ary[$_v->{gno}] =~ m/^--[a-z]/i ) {
			my @longops;
			my $longname;

			@longops = split (/=/o, $_ary[$_v->{gno}]);
			$longname = substr ($longops[0], 2);
			$_v->{optarg} = $longops[1];

			$opt = $_v->{longopt}->{$longname};

			if ( ! $opt ) {
				printf "getopt: options --%s don't support\n", $longname;
				$_v->{getopt_err} = 1;
				return "";
			}

			if ( $_optstr =~ m/$opt:/ ) {
				if ( ! $_v->{optarg} ) {
					$_v->{gno}++;
					$_v->{optarg} = $_ary[$_v->{gno}];
				}
				
				if ( ! $_v->{optarg} ) {
					printf "getopt: option --%s must need option value\n", $longname;
					$_v->{getopt_err} = 1;
					return "";
				}
			}

			last LOOP1;
		}
		# case by short option
		elsif ( $_ary[$_v->{gno}] =~ m/^-[a-z]/i ) {
			my $_olen = length ($_ary[$_v->{gno}]) - 1;

			$opt = substr ($_ary[$_v->{gno}], 1, 1);

			#printf "### _v->{gno}: %d ### opt : %s ### _v->{optcno}: %d ### olen: %d ### optstr: %s\n",
			#		$_v->{gno}, $opt, $_v->{optcno}, $_olen, $_optstr;

			# wheb require option value
			if ( $_optstr =~ m/$opt:/ ) {
				if ( $_olen > 1 ) {
					$_v->{optarg} = substr ($_ary[$_v->{gno}], 2);
				} else {
					$_v->{optarg} = $_ary[$_v->{gno} + 1];
					$_v->{gno}++;
				}

				if ( ! $_v->{optarg} ) {
					printf "getopt: -%s must need option value\n", $opt;
					$_v->{getopt_err} = 1;
					return "";
				}
			} else {
			# when don't require option value
				my $tmpstr;
				my $_tlen;
				my $_optok = 0;
				my $i;

				if ( $_olen > 1 ) {
					printf "getopt: option %s don't support\n", $_ary[$_v->{gno}];
					$_v->{getopt_err} = 1;
					return "";
				}

				$tmpstr = $_optstr;
				$tmpstr =~ s/[a-z]://i;
				$_tlen = length ($tmpstr);

				O_CHK: for ( $i=0; $i<$_tlen; $i++ ) {
					$_optok = 1 if ( substr ($tmpstr, $i, 1) eq $opt );
					last O_CHK if ( $_optok == 1 );
				}

				if ( ! $_optok ) {
					printf "getopt: option -%s don't support\n", $opt;
					$_v->{getopt_err} = 1;
					return "";
				}
			}

			last LOOP1;
		}
		# case by commadn arg
		else {
			if ( $_ary[$_v->{gno}] eq "--" ) {
				print "getopt: - is unknown option\n";
				$_v->{getopt_err} = 1;
				return "";
			}

			push (@{$_v->{optcmd}}, $_ary[$_v->{gno}]);
			# plus 1, commad argumemts number
			$_v->{optcno}++;
			$_v->{gno}++;

			next LOOP1;
		}
	}

	$_v->{gno}++;

	return $opt;
}

1;

__END__

=head1 NAME

Byspam::Getopt - perl getopt module with long option as C sytle

=head1 SYNOPSIS

  package Byspam::Getopt;
  use Byspam::Getopt;

  $o = new Byspam::Getopt;
  $ov = $o->{_var};

  $o->getopt ("short_opt_list", $#ARGV, @ARGV);

=head1 DESCRIPTION

  Byspam::Getopt 패키지는 펄에서 C sytel 의 getopt 를 사용 가능 하게 한다.
  간단하게 예제로 설명을 하도록 한다. 아래의 예제는

  C<./script.pl -c -d asdf -x argument1 argument2>

  의 구조를 가지도록 코딩을 할 것이다. 또한, -c 옵션은 --cmd 로, -d 옵션은
  --dir 로, -x 옵션은 --exec 로 사용할 수 있게 할 것이다.

  -d 옵션과 같이 옵션의 값이 있어야 하는 경우의 표현은, 다음과 같이 사용이
  가능하다.

  C<-d value>
  C<-dvalue>
  C<--dir=value>
  C<--dir value>





  # 패키지를 선언한다.
  use Byspam::Getopt;

  my $opt = "";
  my $help = "도움말\n";

  # Getopt 패키지에서 사용될 것들을 $o 변수에 참조한다.
  #
  my $o = new Byspam::Getopt;

  # Getopt 패키지에서 사용될 변수들을 $ov 에 참조한다.
  #
  my $ov = $o->{_var};

  # 기본 변수를 초기화 한다.
  #
  $ov->{gno} = 0;       # @ARGV 의 순서를 저장
  $ov->{optcno} = 0;    # 옵션 분석 후, 옵션 외의 나머지 argument 수

  # long option 을 short option 에 매치를 시킴. long option 을 사용하지 않
  # 을 것이라면 선언하지 않아도 상관 없음.
  #
  $ov->{longopt} = {
    'cmd'  => 'c',
    'dir'  => 'd',
    'exec' => 'e',
  };

  while ( 1 ) {
    # getopt 를 호출한다. 첫번째 argument 는 short option 의 리스트를 지정
    # 한다. C 의 getopt 와 동일한 형태로 지정을 하며, 옵션 뒤에 ':' 문자가
    # 지정 되면 옵션 값이 있어야 한다는 의미이다.  두번째 argument 는 ARGV
    # 배열의 숫자를 넣는다.
    #
    $opt = $o->getopt ("cd:xh", $#ARGV + 1, @ARGV);

    # $opt 의 값이 없으면 roop 를 종료한다.
    # getopt 는 옵션의 분석 완료 후나, 에러가 발생할 경우 빈 값을 리턴한다.
    #
    last if ( ! $opt );

    #각 옵션에 매칭되는 정보를 지정한다.
    #
    my $cmd = 0;
    my $dir = "";
    my $exec = 0;

    SWITCH: { 
        ( $opt eq "c" ) and do {
            $cmd = 1; 
            last SWITCH;
        };  
        ( $opt eq "d" ) and do {
            # 변수의 값은 $ov->{optarg} 로 가지고 온다
            #
            if ( ! $ov->{optarg} ) {
                print "$help\n"; 
                exit (1);
            }   
            $dir = $ov->{optarg};
            last SWITCH;
        };  
        ( $opt eq "x" ) and do {
            $exec = 1;
            last SWITCH;
        };
        printf "$help\n";
        exit;
    }
  }

  # getopt_err 은 getopt 가 비정상 종료를 했을 경우 1 의 값을 가진다.
  #
  print $help if ( $ov->{getopt_err} );

  # 옵션 외에 2개의 인자를 가져야 하므로 다음의 검사를 한다.
  # 인자의 값은 optcno 로 체크한다.
  #
  print $help if ( $ov->{optcno} != 2 );

  printf "%-10s : %s\n", "cmd", $cmd;
  printf "%-10s : %s\n", "dir", $dir;
  printf "%-10s : %s\n", "exec", $exec;

  # 넘겨진 인자는 순서대로 optcmd 배열에 들어간다.
  #
  print  "%-10s : %s\n", "argument 1", $ov->{optcmd}->[0];
  print  "%-10s : %s\n", "argument 2", $ov->{optcmd}->[1];

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noet sw=4 ts=4 fdm=marker
# vim<600: noet sw=4 ts=4
#
