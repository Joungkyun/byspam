#
# Perl - C style getopt library include long option functon
#
# scripted by JoungKyun Kim <http://www.oops.org>
#
# $Id: Getopt.pm,v 1.1 2004-11-27 18:50:32 oops Exp $
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

  Byspam::Getopt ��Ű���� �޿��� C sytel �� getopt �� ��� ���� �ϰ� �Ѵ�.
  �����ϰ� ������ ������ �ϵ��� �Ѵ�. �Ʒ��� ������

  C<./script.pl -c -d asdf -x argument1 argument2>

  �� ������ �������� �ڵ��� �� ���̴�. ����, -c �ɼ��� --cmd ��, -d �ɼ���
  --dir ��, -x �ɼ��� --exec �� ����� �� �ְ� �� ���̴�.

  -d �ɼǰ� ���� �ɼ��� ���� �־�� �ϴ� ����� ǥ����, ������ ���� �����
  �����ϴ�.

  C<-d value>
  C<-dvalue>
  C<--dir=value>
  C<--dir value>





  # ��Ű���� �����Ѵ�.
  use Byspam::Getopt;

  my $opt = "";
  my $help = "����\n";

  # Getopt ��Ű������ ���� �͵��� $o ������ �����Ѵ�.
  #
  my $o = new Byspam::Getopt;

  # Getopt ��Ű������ ���� �������� $ov �� �����Ѵ�.
  #
  my $ov = $o->{_var};

  # �⺻ ������ �ʱ�ȭ �Ѵ�.
  #
  $ov->{gno} = 0;       # @ARGV �� ������ ����
  $ov->{optcno} = 0;    # �ɼ� �м� ��, �ɼ� ���� ������ argument ��

  # long option �� short option �� ��ġ�� ��Ŵ. long option �� ������� ��
  # �� ���̶�� �������� �ʾƵ� ��� ����.
  #
  $ov->{longopt} = {
    'cmd'  => 'c',
    'dir'  => 'd',
    'exec' => 'e',
  };

  while ( 1 ) {
    # getopt �� ȣ���Ѵ�. ù��° argument �� short option �� ����Ʈ�� ����
    # �Ѵ�. C �� getopt �� ������ ���·� ������ �ϸ�, �ɼ� �ڿ� ':' ���ڰ�
    # ���� �Ǹ� �ɼ� ���� �־�� �Ѵٴ� �ǹ��̴�.  �ι�° argument �� ARGV
    # �迭�� ���ڸ� �ִ´�.
    #
    $opt = $o->getopt ("cd:xh", $#ARGV + 1, @ARGV);

    # $opt �� ���� ������ root �� �����Ѵ�.
    # getopt �� �ɼ��� �м� �Ϸ� �ĳ�, ������ �߻��� ��� �� ���� �����Ѵ�.
    #
    last if ( ! $opt );

    #�� �ɼǿ� ��Ī�Ǵ� ������ �����Ѵ�.
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
            # ������ ���� $ov->{optarg} �� ������ �´�
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

  # getopt_err �� getopt �� ������ ���Ḧ ���� ��� 1 �� ���� ������.
  #
  print $help if ( $ov->{getopt_err} );

  # �ɼ� �ܿ� 2���� ���ڸ� ������ �ϹǷ� ������ �˻縦 �Ѵ�.
  # ������ ���� optcno �� üũ�Ѵ�.
  #
  print $help if ( $ov->{optcno} != 2 );

  printf "%-10s : %s\n", "cmd", $cmd;
  printf "%-10s : %s\n", "dir", $dir;
  printf "%-10s : %s\n", "exec", $exec;

  # �Ѱ��� ���ڴ� ������� optcmd �迭�� ����.
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
