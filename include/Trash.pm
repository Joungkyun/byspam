#
# Byspam Trash Viewer Library
#
# scripted by JoungKyun Kim <http://www.oops.org>
#
# $Id: Trash.pm,v 1.10 2004-12-06 14:05:39 oops Exp $
#

package Byspam::Trash;
use strict;

use Byspam::Common;
use Byspam::Mail;
use Byspam::Parse;
use File::Copy;

my $cm = new Byspam::Common;

sub new {
	my $self = {};
	return bless $self;
}

sub getHomePath {
	my $self = shift if ref ($_[0]);
	my $check = $_[0];
	my $path  = "/etc/passwd";
	my @text  = "";
	my $me    = "";

	@text = $cm->getContext_r ($path);

	foreach my $_line ( @text ) {
		if ( $_line =~ m/^${check}:/i ) {
			my @part = ();
			@part = split (/:/, $_line);
			$me = $cm->trim ($part[5]);
			$me =~ s/\/$//g;
			last;
		}
	}

	return $me;
}

sub getTrashList {
	my $self = shift if ref ($_[0]);
	my $_path = $_[0];

	my @list = ();
	my @me = ();

	if ( -d $_path ) {
		@list = glob ("$_path/spam-*");
	}

	foreach my $_line (@list) {
		next if ( -d $_line );

		$_line =~ s/.*\/([^\/]+)$/$1/g;
		push (@me, $_line);
	}

	@me = sort { $b cmp $a } @me;

	return @me;
}

sub totalPage {
	my $self = shift if ref ($_[0]);
	my ( $no, $li ) = @_;

	my $_share;
	my $_res;
	my $_me;

	$_share = $no / $li;
	$_res   = $no % $li;
	$_me    = ( $_res > 0 ) ? int $_share + 1 : int $_share;

	return $_me;
}

sub nextFunc {
	my $_case = $cm->trim ($main::_read);

	CASE: {
		# program exit mode
		( $_case eq "q" or $_case eq "x" ) and do {
			exit 0;
		};

		# back list mode
		( $_case eq "b" ) and do {
			if ( ! $main::_nullchk ) {
				$main::_start = $main::_start - ($main::_limit * 2);
				$main::_until = $main::_until - ($main::_limit * 2);
				$main::_page  = $main::_page - 1;
			} else {
				$main::_start = $main::_startl - $main::_limit;
				$main::_until = $main::_untill - $main::_limit;
				$main::_page  = $main::_page - 1;
			}

			# if _start < 0
			if ( $main::_start < 0 ) {
				$main::_start = 0;
				$main::_until = 0;
				$main::_page = 1;
			}

			$main::_page = 1 if ( $main::_page < 1 );

			last CASE;
		};

		# delete trash mode
		( $_case =~ m/d[ \t]+(.*)/ ) and do {
			my @_dellist = split (/[ \t]+/, $1);

			foreach my $_d ( @_dellist ) {
				my $_dno = $_d - 1;
				unlink ("$main::_path/$main::spamlist[$_dno]");
				print "rm -f $main::_path/$main::spamlist[$_dno]\n";
			}

			@main::spamlist = getTrashList ($main::_path);
			$main::spamno = @main::spamlist;
			$main::_tpage = totalPage ($main::spamno, $main::_limit);

			$main::_page = $main::_tpage < $main::_page ? $main::_page -1 : $main::_page;
			if ( $main::_page < 1 ) {
				$cm->printError ("WORN : No exists trash file\n");
				exit 0;
			}

			$main::_start = $main::_page * $main::_limit - $main::_limit;
			$main::_until = $main::_page * $main::_limit - $main::_limit;

			last CASE;
		};

		# view trash file mode
		( $_case =~ m/^[0-9]+$/ ) and do {
			my $_dno = int ( $_case - 1 );
			printTrash ($main::_path, $main::spamlist[$_dno], $main::_user, $main::_sublen, $main::_from);

			$main::_start = $main::_startl;
			$main::_until= $main::_untill;

			last CASE;
		};

		# any mode ( this case must go next page)
		$main::_page++;
		$main::_page = $main::_tpage if ( $main::_page > $main::_tpage );
	}
}

sub splitMail {
	my $self = shift if ref ($_[0]);

	my $_tmail	= $_[0];
	my $st      = 0;
	my $mailTmp = "";
	my @mailx   = ();

	if ( ! -f $_tmail ) {
		$cm->printError ("Error: Can not found $_tmail\n");
		exit 1;
	}

	open (fileHandle, $_tmail);
	foreach (<fileHandle>) {
		if ( m/^From[ ]+[^@]+@[^ ]+[ ]+[A-Z][a-z]{2}[ ]+[A-Z][a-z]{2}[ ]+/ ) {
			if ( $st ) {
				push (@mailx, $mailTmp);
			} else {
				$st = 1;
			}
			$mailTmp = $_;
		} else {
			$mailTmp .= $_;
		}
	}

	push (@mailx, $mailTmp);
	close (fileHandle);

	return @mailx;
}

sub recoveryMail {
	my $self = shift if ref ($_[0]);
	my ( $u, $m, $_s ) = @_;

	my $_inbox = "$main::inbox/$u";
	$_inbox = $_s if ( $_s );

	if ( ! -d $_inbox ) {
		open (fileHandle, ">>$_inbox");
		print fileHandle "$m\n";
		close (fileHandle);

		return 0;
	}

	return 1;
}

sub rewriteTrash {
	my $self = shift if ref ($_[0]);
	my ( $p, $n, @m ) = @_;

	my $_tmps = $p ? "$p/$n.$$" : "$n.$$";
	my $_new  = $p ? "$p/$n" : $n;

	open (fileHandle, ">$_tmps");
	foreach ( @m ) {
		print fileHandle "$_\n";
	}
	close (fileHandle);

	if ( -f "$_tmps" && ! -d $_new ) {
		copy ($_tmps, $_new);
		unlink "$_tmps";
	}
}

sub printTrash {
	my $self = shift if ref ($_[0]);
	my $ps = new Byspam::Parse;
	my $mx;

	my ( $path, $name, $user, $sublen, $fromis ) = @_;
	my $tpath     = ( $path ) ? "$path/$name" : $name;
	my @mails     = ();
	my $mailSize  = 0;
	my @tmpMail   = ();

	my @subject   = ();
	my @from      = ();
	my @date      = ();
	my @body      = ();
	my $filedates = "";
	my $p_page    = 1;

	@mails = splitMail ($tpath);
	chomp (@mails);

	foreach my $permail ( @mails ) {
		my $tsub;
		my $tfrom;

		$permail =~ s/\r?\n/\n!byspamsplit!/g;
		@tmpMail = split (/!byspamsplit!/, $permail);

		$mx = Byspam::Mail->new (\@tmpMail);

		$main::_hdebug && print "### " . $mx->header("Subject") ."\n";
		$tsub = $ps->parseHeader ($mx->header ("Subject"));
		$tsub = $tsub ? $cm->trim ($tsub) : "No Subject";

		$tfrom = $ps->parseHeader ($mx->header ("From"));
		$tfrom = $tfrom ? $tfrom : "No From";

		push (@subject, $tsub);
		push (@from, $tfrom);
		push (@date, $mx->header ('Date'));
		push (@_byspam, $mx->header ('X-BySpam-Filter'));

		$main::_bdebug && print "### " . $mx->header("Subject") ."\n";
		push (@body, $ps->getBody ($mx));
		$permail =~ s/!byspamsplit!//g;
	}

INIT:
	$mailSize = @mails;

	my $__limit = $main::_limit;
	my $lastpage = $mailSize/$__limit;
	my $lastchk  = int $lastpage;
	$lastpage = $lastchk + 1 if ( $lastchk < $lastpage );

	$filedates = $name;
	$filedates =~ s/[^-]+-(.*)/$1/g if ( ! $main::_direct );

	my $start;
	my $until;
	my $cmd;
	my $less = `less --help`;

	my $printBody;

	$p_page = $p_page > 1 ? $p_page : 1;
	while (1) {
		system ("clear");
		print "=============================================================================\n" .
			  "[1;37mby SPAM Trash Viewer[7;0m $main::version by JoungKyun Kim <http://www.oops.org>\n" .
			  "Command [ [1;37mq[7;0muit | [1;37mn[7;0mum | [1;37md[7;0mel | " .
			  "[1;37mr[7;0mecovery | enter - next | b - back | p - jump ]\n" .
			  "=============================================================================\n";
		if ( $main::_direct ) {
			print "Current File: $filedates\n";
		} else {
			print "Current Date: $filedates\n";
		}
		print "$p_page page / total $lastpage pages\n\n";

		$start = ($p_page > 1 ) ? $mailSize - ($p_page * $__limit - $__limit) - 1 : $mailSize - 1;
		$until = ($start - $__limit < -1 ) ? -1 : $start - $__limit;

		my $i;
		my $filtersubject;
		my $filterlength;
		my $filterfrom;

		for($i=$start;$i>$until;$i--) {
			$filterlength = ( ! $sublen ) ? 60 : $sublen;
			$filtersubject = substr($subject[$i], 0, $filterlength);
			$filtersubject =~ s/(([\x80-\xff].)*)[\x80-\xff]?$/$1/;
			printf "%6s. %s\n", $i + 1, $filtersubject;
			if ( $fromis ) {
				$filterfrom = $from[$i];
				$filterfrom =~ s/\"|^[\s]*//g;
				$filterfrom = $cm->trim ($filterfrom);
				printf "%8sFROM: %s\n", "", $filterfrom;
			}
		}

		print "-----------------------------------------------------------------------------\n" .
			  "[1;37mCommand:[7;0m ";

		$cmd = <STDIN>;
		$cmd = $cm->trim ($cmd);

		# view mail context
		if ( $cmd =~ m/^[0-9]+$/ ) {
			if ($cmd <= $start + 1 && $cmd > $until + 1 ) {
				my $mailno = $cmd - 1;
				system("clear");
				$printBody = "=============================================================================\n" .
							 "by SPAM Trash Viewer $main::version by JoungKyun Kim <http://www.oops.org>\n" .
							 "Command [ q - quit | space - next page | enter - next line | b - prev page ]\n" .
							 "=============================================================================\n" .
							 "$p_page page / total $lastpage pages\n\n".
							 "Mail No. $cmd\n".
							 "Date   : $date[$mailno]\n".
							 "From   : $from[$mailno]\n".
							 "Filter : $_byspam[$mailno]\n".
							 "Subject. $subject[$mailno]\n\n".
							 "$body[$mailno]\n";
  
				if ( $less ) {
					$printBody =~ s/'/`/g;
					system("echo '$printBody' | less -e");
					redo;
				} else { 
					print "$printBody"; 
					print "\nDo you want to continue? [y/n] : ";
					$cmd = <STDIN>;
					chomp $cmd;
  
					if($cmd !~ /^(y|$)/i) { last; }
					else { redo; }
				} 
			} else {
				print "Out of a scope of mail list\n";
				redo;
			}
		}

		# delete or recovery article mode
		elsif ( $cmd =~ m/^(d|r)[\s]+([0-9]+)([\s]+.*)*/ ) {
			my $_mode  = $1;
			my $_actno = $2 - 1;
			my $_s     = 0;

			$_savefile = $cm->trim ($3) if ( $3 );

			# if delete no < 0, redo current page;
			redo if ( $_actno < 0 );
			redo if ( $_actno >= $mailSize );

			if ( $_mode eq "r" && $main::_direct && ! $main::_root ) {
				$_s = 1;
			} else {
				# recovery mode
				$_s = recoveryMail ($user, $mails[$_actno], $_savefile) if ( $_mode eq "r" );
				$_s && redo;
			}
			$_s && redo;

			# article removed
			splice (@mails, $_actno, 1);
			splice (@subject, $_actno, 1);
			splice (@date, $_actno, 1);
			splice (@body, $_actno, 1);
			splice (@from, $_actno, 1);

			# rewrite original file
			rewriteTrash ($path, $name, @mails);

			goto INIT;
		}

		# jump page
		elsif ( $cmd =~ m/^p[\s]+([0-9]+)/ ) {
			$p_page = $1;
			if ( $p_page < 1 ) { $p_page = 1; }
			elsif ( $p_page > $lastpage ) { $p_page = $lastpage; }

			redo;
		}

		elsif ($until == -1 && $cmd !~ m/^b/i) { last; }
		elsif($cmd !~ m/^(y|b|\s*$)/i) { last; }
		elsif($cmd =~ m/^b/i && $p_page eq 1) { }
		elsif($cmd =~ m/^b/i && $p_page > 1) { $p_page--;  }
		else { $p_page++; }

	}
}

1;

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noet sw=4 ts=4 fdm=marker
# vim<600: noet sw=4 ts=4
#
