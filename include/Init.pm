#
# Byspam Initial functions
#
# $Id: Init.pm,v 1.1 2004-12-03 10:55:48 oops Exp $
#

package Byspam::Init;

use strict;
use Byspam::Common;
my $cm = Byspam::Common->new ();
my $_shmout = 0;
my $_shmdeb = 0;


# configuration shm information
my %shmconf = (
				"key"  => 0x11001000,
				"size" => 65536
);

eval ("use IPC::ShareLite");
$_shmout    = 1 if ( $@ );


my $confdir = "@confdir@";
my $conf    = "byspam.conf";
my %_opt;
my %_filter;

$conf       = "$confdir/$conf";

$_shmout = 1;
sub new {
	my $self = {};

	$self->{_shmout}   = $_shmout;
	$self->{_confkey}  = $shmconf{'key'};
	$self->{_confsize} = $shmconf{'size'};
	$self->{_conffile}  = $conf;

	# Configuration Init
	#

	if ( $_shmout ) {
		$self->{conf} = $cm->formatConfig ($conf);
	} else {
		# init configuration shared memory
		$self->{conf} = byspamShmInit ($shmconf{'key'}, $shmconf{'size'});

		# not exists configuration on shared memory, load configuration
		if ( ! $self->{conf}->fetch ) {
			my $_pconf = $cm->formatConfig ($conf);
			$_pconf && $self->{conf}->store ($_pconf);
			$_shmdeb && print "load configuratoins\n";
		}
	}

	%_opt = $cm->parseConfig ($self->{conf});

	# Filter Init
	#

	my $keyname;
	my $keyfile;
	my $shmkey;
	my $shmsize;
	my $_filters;

	# init filter shared memory
	foreach my $_shmi ( @{$_opt{basics}} ) {
		$_shmi =~ m/^([^:]+):([^:]+):([^:]+):([^:]+)$/i;
		$keyname = lc ($1);
		$keyfile = "$_opt{filterDir}/$2";
		$shmkey  = hex $3;
		$shmsize = $4 ? int $4 : 65536;

		if ( $_shmout ) {
			$_filter{$keyname} = $cm->filterText ($keyfile);
		} else {
			$self->{$keyname} = byspamShmInit ($shmkey, $shmsize);

			if ( ! $self->{$keyname}->fetch ) {
				if ( -f "$keyfile" ) {
					$_filters = $cm->filterText ($keyfile);
					$_filters && $self->{$keyname}->store ($_filters);
					$_shmdeb && printf "load %12s filter\n", $keyname;
				}
			}
		}
	}

	$_opt{'allows'} =~ m/^([^:]+):([^:]+):([^:]+)$/i;
	$keyfile = "$_opt{filterDir}/$1";

	if ( $_shmout ) {
		$_filter{'allows'} = $cm->filterText ($keyfile);
	} else {
		$self->{'allows'} = byspamShmInit (hex $2, int $3);

		if ( ! $self->{'allows'}->fetch ) {
			if ( -f "$keyfile" ) {
				$_filters = $cm->filterText ($keyfile);
				$_filters && $self->{'allows'}->store ($_filters);
				$_shmdeb && printf "load %12s filter\n", "allows";
			}
		}
	}

	$_opt{'ignore'} =~ m/^([^:]+):([^:]+):([^:]+)$/i;
	$keyfile = "$_opt{filterDir}/$1";

	if ( $_shmout ) {
		$_filter{'ignore'} = $cm->filterText ($keyfile);
	} else {
		$self->{'ignore'} = byspamShmInit (hex $2, int $3);

		if ( ! $self->{'ignore'}->fetch ) {
			if ( -f "$keyfile" ) {
				$_filters = $cm->filterText ($keyfile);
				$_filters && $self->{'ignore'}->store ($_filters);
				$_shmdeb && printf "load %12s filter\n", "ignore";
			}
		}
	}


	return bless $self;
}

sub opts {
	my $self = shift if ref ($_[0]);
	my $_name = $_[0];

	if ( $_name =~ m/^([a-z]+)\[([0-9]+)\]$/i ) {
		$_opt{$1}[$2] && return $_opt{$1}[$2];
	}

	$_opt{$_name} && return $_opt{$_name};

	return "";
}

sub filter {
	my $self = shift if ref ($_[0]);
	my $_name = $_[0];
	my $_me = "";

	if ( ! $_shmout ) {
		$_me = $self->{$_name}->fetch if ( $self->{$_name} );
	} else {
		$_me = $_filter{$_name} if ( $_filter{$_name} );
	}

	return $_me;
}

sub byspamShmInit {
	my $self = shift if ref ($_[0]);
	my ( $_initkey, $_size ) = @_;

	my $_shm;

	$_shm = IPC::ShareLite->new (
					-key     => $_initkey,
					-create  => 1,
					-destroy => 0,
					-size    => $_size,
					-mode    => 0600
	);

	return $_shm;
}

sub shmStore {
	my $self = shift if ref ($_[0]);
	my ( $_ref, $_data ) = @_;

	$_ref->store ($_data);
}

sub shmFetch {
	my $self = shift if ref ($_[0]);
	my $_ref  = $_[0];

	my $_me = $_ref->fetch;

	return $_me;
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
