#
# Byspam Common functions
#
# $Id: Common.pm,v 1.2 2004-11-29 06:02:30 oops Exp $
#

package Byspam::Common;

use strict;

sub new {
  my $self = {};

  return bless $self;
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
