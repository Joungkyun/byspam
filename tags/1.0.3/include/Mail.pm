#
# Byspam Mail library modules - parsing header and body
#
# $Id$
#

package Byspam::Mail;

use strict;

my %_hp;

sub new {
	my $self = shift;
	my $type = ref ($self) || $self;
	my $_fm = $_[0];
	my %_ps;

	my $me = bless {}, $type;

    %_ps = parseFormat (@{$_fm}) if ( $_fm );

	if ( %_ps ) {
		$me->{_header} = $_ps{header};
		$me->{_body} = $_ps{body};

		%_hp = parseHeader ($_ps{header});
	}

	return $me;
}

sub header {
	my $self = shift if ref ($_[0]);
	my $_hd = $_[0];
	$_hd = lc ($_hd) if ( $_hd);

	return $self->{_header} if ( ! $_hd );
	return $_hp{$_hd} if ( $_hp{$_hd} );

	return "";
}

sub body {
	my $self = shift if ref ($_[0]);
	return $self->{_body};
}

sub parseFormat {
	my $self = shift if ref ($_[0]);
	my @_fd = @_;
    my %parse;

	my $_type = "h";
	my $_h = "";
	my $_b = "";

	foreach my $_s ( @_fd ) {
		$_s =~ s/^[\s]+|[\s]+$//g;
		$_type = "b", next if ( $_type ne "b" && ! $_s );

		SWITCH: {
			( $_type eq "h" ) and $_h .= "$_s\n", last SWITCH;
			$_b .= "$_s\n", last SWITCH;
		}
	}

	$parse{header} = $_h;
	$parse{body} = $_b;

	$parse{header} =~ s/^[\s]+|[\s]+$//g;
	$parse{body} =~ s/^[\s]+|[\s]+$//g;

	return %parse;
}

sub parseHeader {
	my $self = shift if ref ($_[0]);
	my $_head = $_[0];
	my @_head = ();
	my $_ph   = "";
	my %parse;

    my $pos = 0;

	@_head = split (/\n/, $_head);

	foreach my $_r ( @_head ) {
		next if ( $_r =~ m/^From[\s]+/i );
		$pos = index ($_r, ": ");

		SWITCH: {
			# exists header
			( $pos > 0 ) and do {
				my $_h    = "";
				my $_v    = "";

				$_h = lc (substr ($_r, 0, $pos));
				$_ph = $_h;
				$_v = substr ($_r, $pos + 2);
				$_v =~ s/^[\s]*|[\s]*$//g;

				# already exists same header
				$parse{$_h} = $parse{$_h} ? $parse{$_h}.$_v : $_v;
				last SWITCH;
			};
			# if none exists header, added primary header
			( $_ph ) and do {
				$parse{$_ph} .= "\n$_r";
				last SWITCH;
			};
			next;
		}
	}

	return %parse;
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
