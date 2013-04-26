#
# Byspam Common functions
#
# $Id$
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

# check number of Received header. It is smaller than 2,
# it's regards as spam bot
sub checkReceived {
	my $self = shift if ref ($_[0]);
	my $_headers = $_[0];

	# If header don't exists, it regards parse error, and return no spam.
	return 0 if ( ! $_headers );

	my @lines = split (/\n/, $_headers);
	my $rcout = 0;
	foreach my $_v ( @lines ) {
		return 100 if ( $_v =~ /Received-SPF:/ && $_v =~ /authenticated connection/ );
		$rcout++ if ( $_v =~ /^Received: / );
	}

	return 1 if ( $rcout < 2 );

	return 0;
}

sub printError {
	my $self = shift if ref ($_[0]);
	my $_msg = $_[0];

	print STDOUT $_msg;
}

sub formatConfig {
	my $self = shift if ref ($_[0]);
	my $file = $_[0];

	if ( ! -f "$file" ) {
		print STDERR "\n" .
					 "    Configuration file missing.\n" .
					 "    Check \"$file\" file\n" .
					 "\n";
		exit 1;
	}

	my @file = getContext_r ($file);
	my $_me;

	foreach my $_line ( @file ) {
		$_line = trim ($_line);
		$_line =~ s/(#|;).*//g;
		$_line =~ s/[\s]*=[\s]*"?/=/g;
		$_line =~ s/^\$|"$//g;

		next if ( ! $_line );

		$_me .= "$_line;";
	}

	return $_me;
}

sub parseConfig {
	my $self = shift if ref ($_[0]);
	my $_ref = $_[0];
	my %_me;
	my @_var;
	my $conf;

	if ( ref ( $_ref ) ) {
		$conf = $_ref->fetch;
	} else {
		$conf = $_ref;
	}
	my @conf = split (/;/, $conf);

	foreach my $_v ( @conf ) {
		@_var = split (/=/, $_v);
		if ( $_var[0] =~ m/([a-z]+)\[([0-9]+)\]/i ) {
			$_me{$1}[$2] = $_var[1];
		} else {
			$_me{$_var[0]} = $_var[1];
		}
	}

	return %_me;
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
