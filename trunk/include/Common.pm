#
# Byspam Common functions
#
# $Id: Common.pm,v 1.1 2004-11-27 18:50:32 oops Exp $
#

package Byspam::Common;

use strict;

sub new {
  my $self = {};

  return bless $self;
}

# print help message and save directory
#
sub printHelp {
	my $lc;
	my $USAGES;

	$lc = $main::charset;
	my @helps = ();
	if( $lc eq "EUC-KR" ) {
		$USAGES = "사용법";
		@helps = (
				  "현재 메세지를 출력",
				  "인자로 넘긴 메일형식의 절대경로 파일을 체크 [ 디버그 모드 ]",
				  "메일 형식을 파이프로 넘기는 형식",
				  "메일 형식을 파이프로 넘기는 형식 [ 디버그 모드 ]"
		);
	} else {
		$USAGES = "USAGE";
		@helps = (
				  "print this message",
				  "debug mode with file(absolte path) of mail form",
				  "put mail form with pipe",
				  "debug mode with put mail form with pipe",
		);
	}

	print "\n$USAGES : \n";
	print "    byspamFilter [ -h --help ]\n";
	print "          => ${helps[0]}\n\n";
	print "    byspamFilter -d mail_form_file_pull_path \n";
	print "          => ${helps[1]}\n\n";
	print "    cat mail_form_file | byspamFilter \n";
	print "          => ${helps[2]}\n\n";
	print "    cat mail_form_file | byspamFilter -p \n";
	print "          => ${helps[3]}\n\n";

	exit 1;
}

# removed first and last blank charactors in variable
#
sub trim {
	my $self = shift if ref ($_[0]);

	my $_r = $_[0];
	$_r =~ s/^[\s]+|[\s]+$//g;

	return $_r;
}

# get context of file
#
sub getContext_rr {
	my $self = shift if ref ($_[0]);

	my ($_file, $_mode) = @_;
	my @list = ();

	$_mode = 0 if ( ! $_mode );

	if ( -f "$_file" ) {
		open (fileHandle, $_file);
		foreach ( <fileHandle> ) {
			$_ = trim ($_) if $_mode == 1;
			push @list, $_;
		}
		close (fileHandle);
	}

	return @list;
}

sub getContext_r {
	my $self = shift if ref ($_[0]);
	my $_file = $_[0];
	my @_list = ();

	@_list = getContext_rr ($_file, 1);

	return @_list;
}

sub getContext {
	my $self = shift if ref ($_[0]);

	my $_file = $_[0];
	my $list = "";

	if ( -f "$_file" ) {
		open (fileHandle, $_file);
		foreach ( <fileHandle> ) {
			$list .= $_;
		}
		close (fileHandle);
	}

	return $list;
}

sub getJoin_rr {
	my $self = shift if ref ($_[0]);
	my (@_array) = @_;
	my $_tmp;
	my $_return;

	foreach $_tmp ( @_array ) {
		$_return .= $_tmp;
	}

	$_return = "" if ( ! $_return );

	return trim ($_return);
}

sub filterText {
	my $self = shift if ref ($_[0]);

	my $list;
	my $aLine;
	my $_file = $_[0];

	if ( -f "$_file" ) {
		open (fileHandle,$_file);
		foreach ( <fileHandle> ) {
			if(! /^#/ig && ! /^[ \t]*$/g ) {
				$aLine = trim ($_);
				$list .= ! $list ? $aLine : "|$aLine";
			}
		}
		close(fileHandle);
	}

	$list = "" if ( ! $list );

	return trim ($list);
}

# check of no content
sub noContentCheck {
	my $self = shift if ref ($_[0]);

	my $content = $_[0];

	return 1 if ( ! $content );

	$content =~ s/[\s]|&nbsp;//ig;
	$content =~ s/<html>.*<\/head>//ig;
	$content =~ s/<[^>]*>//ig;

	return 1 if ( ! $content );

	return 0;
}

1; # keep require happy

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noet sw=4 ts=4 fdm=marker
# vim<600: noet sw=4 ts=4
#
