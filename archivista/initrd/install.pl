#!/usr/bin/perl

=head1 install.pl v1.0.35 (c) 25.11.2011 by Archivista GmbH, Urs Pfister

An easy installer for ArchivistaVM written in perl

=cut

use strict;

my $lang = ""; # language to use (de,en,..)
my $iso = ""; # we use an iso file to upload
my $auto = 0; # non interactive way to update
my $xorg = 0; # set xorg server
my $menu = 0; # call the programm with a main menu mode
my $network = 0; # set a new ip address (with interface)
my $geteth = 0; # give back the used eth device
my $getip = 0; # give back ip address
my $getcidr = 0; # give back cidr noation of submask
my $getsm = 0; # give back submask
my $getgw = 0; # give back gateway
my $getdns = 0; # give back dns
my $getipcidr = 0; # give back ip with cidr noation
my $getnet = 0; # give back the current network information
my $eth = ""; # set the desired eth interface
my $ip = ""; # set a new ip
my $cidr = ""; # set a new cidr (submask)
my $sm = ""; # set a new submask
my $gw = ""; # set a new gateway
my $dns = ""; # set a new dns 
my $ipcidr = ""; # set a new ip and submask (cidr)
my $debuglevel = 0; # where to stop the installation
my $text = 0; # 1=use simple chars (for telnet sessions)
my $killit = 0; # kill all hard disk (always complete installation)
my $noraid = 0; # we don't want to have software raid detection 
my $confsave = 0; # save the current configuration
my $confload = 0; # load the current configuration
my $raidinstall = ""; # default raid level (starting option)

my $opt = shift;
my @opts = split(',',$opt);
my $startup = `cat /proc/cmdline 2>/dev/null`;
foreach my $arg (@opts) {
  my ($arg1,$val1) = split("=",$arg);
	$lang = "de" if $arg eq "de";
	$iso = $arg if $arg =~ /(\.iso)$/;
	$auto=1 if $arg eq "auto";
	$network = 1 if $arg eq "network";
	$xorg = 1 if $arg eq "xorg";
	$menu = 1 if $arg eq "menu";
	$geteth = 1 if $arg eq "geteth";
	$getip = 1 if $arg eq "getip";
	$getcidr = 1 if $arg eq "getcidr";
	$getsm = 1 if $arg eq "getsm";
	$getgw = 1 if $arg eq "getgw";
	$getdns = 1 if $arg eq "getdns";
	$getipcidr = 1 if $arg eq "getipcidr";
	$getnet = 1 if $arg eq "getnet";
	$eth=$val1 if $arg eq "eth";
	$ip=$val1 if $arg1 eq "ip";
	$sm=$val1 if $arg1 eq "sm";
	$cidr=$val1 if $arg1 eq "cidr";
	$gw=$val1 if $arg1 eq "gw";
	$dns=$val1 if $arg1 eq "dns";
	$ipcidr=$val1 if $arg1 eq "ipcidr";
	$debuglevel=$val1 if $arg1 eq "debuglevel";
	$text=1 if $arg1 eq "text";
	$killit=1 if $arg1 eq "killit";
	$noraid=1 if $arg1 eq "noraid";
	$confsave=1 if $arg1 eq "confsave";
	$confload=1 if $arg1 eq "confload";
	if ($arg1 eq "raid0" || $arg1 eq "raid1" || $arg1 eq "raid5" ||
	    $arg1 eq "raid6" || $arg1 eq "raid10") {
	  $raidinstall=$arg1;
	}
}
system("setterm -msg off");
system("stty intr undef");
system("modprobe -q ext4");
my $av = install->new($lang,$iso,$auto,$text,$killit,$noraid); # initialize
$av->confcheck($confload,$confsave);
$av->debuglevel($debuglevel); # set debuglevel to stop an installation somewhere
if ($network==1) {
  $av->read_ipvalues(); # read the values for editing
  $av->choose_networking(); # ask for ip address and do a full installation
	$av->save_ipvalues("");
} elsif ($menu==1) {
  $av->menu();
} elsif ($xorg==1) {
  $av->choose_xorg();
} elsif ($getnet==1) {
  $av->read_ipvalues(1); # read the values for editing
	print "IP: ".$av->ip.$av->cidr." -- GW: ".$av->gw." -- NS: ".$av->dns."\n";
} elsif ($geteth==1) {
  $av->read_ipvalues(1); # read the values for editing
	print $av->eth;
} elsif ($getip==1) {
  $av->read_ipvalues(1); # read the values for editing
	print $av->ip;
} elsif ($getcidr==1) {
  $av->read_ipvalues(1); # read the values for editing
	print $av->cidr;
} elsif ($getsm==1) {
  $av->read_ipvalues(1); # read the values for editing
	print $av->submask;
} elsif ($getgw==1) {
  $av->read_ipvalues(1); # read the values for editing
	print $av->gw;
} elsif ($getdns==1) {
  $av->read_ipvalues(1); # read the values for editing
	print $av->dns;
} elsif ($getipcidr==1) {
  $av->read_ipvalues(1); # read the values for editing
	print $av->ip.$av->cidr;
} elsif ($ip ne "" || $cidr ne "" || $sm ne "" || $eth ne "" || 
         $gw ne "" || $dns ne "" || $ipcidr ne "") {
	# CHANGE CURRENT IP ADDRESS
  $av->read_ipvalues(1); # read the values for editing
	$av->eth($eth) if $eth ne "";
	$av->ip($ip) if $ip ne "";
	$av->submask($sm) if $sm ne "";
	$av->cidr($cidr) if $cidr ne "";
	$av->gw($gw) if $gw ne "";
	$av->dns($dns) if $dns ne "";
	$av->set_ipcidr($ipcidr) if $ipcidr ne "";
	$av->save_ipvalues("");
} else { # INSTALLATION (not setup)
  $av->cmdline($startup);
  $av->hello(); # Welcome message
  while ($av->cidr eq "" && $av->hdcurrent eq "") {
    $av->choose_harddisk($raidinstall); # choose the harddisk
	  # we need this line so that we can mount the drive
	  $av->doit("ln -s /proc/mounts /etc/mtab 2>/dev/null");
		if ($av->ram==1) {
      $av->install_ram();
		} else {
	    $av->check_update(); # check if an installation already does exist
	    if ($av->backupinst==0) { # we did not find any installation
        $av->choose_networking(); # ask for ip address and do full installation
	    }
		}
  }
  system("setterm -msg on");
  $av->install() if $av->ram==0; # installation (or update) process
}



package install;

use strict;
use IpMask; # check ip address
use Wrapper; # simple get/set wrapper for perl (written by Archivista GmbH)

# constants for messages
use constant TITLE => 'ArchivistaBox Installer '.
                      '(c) v2011-11-18 by Archivista GmbH, www.archivista.ch';
use constant NETWORK => "network";
use constant ETH => "eth";
use constant IP => "ip";
use constant GW => "gw";
use constant SM => 'sm';
use constant DNS => "dns";
use constant LANGUAGE => "language";
use constant LANG_EN => "lang_en";
use constant LANG_DE => "lang_de";
use constant HELLO1 => "hello1";
use constant HELLO2 => "hello2";
use constant HARDDISK => "harddisk";
use constant GO1 => "go1";
use constant GO2 => "go2";
use constant UP1 => "up1";
use constant UP2 => "up2";
use constant END1 => "end1";
use constant END2 => "end2";
use constant END3 => "end3";
use constant END4 => 'end4';
use constant WAIT => "wait";
use constant CONFIRM => 'confirm';
use constant AVBOX => 'avbox';

use constant FINDCD => "findcd";
use constant FORMATHD => "formathd";
use constant PARTHD1 => "parthd1";
use constant PARTHD2 => "parthd2";
use constant PARTHD3 => "parthd3";
use constant PARTHD4 => "parthd4";
use constant INSTOS => "instos";
use constant FINISH => "finish";
use constant DEFAULTNO => 1;

use constant YES => "yes";
use constant NO => "no";
use constant OK => "ok";
use constant CANCEL => "cancel";

use constant XORG => "xorg";
use constant XDRIVER => "xdriver";
use constant XRES => "xres";
use constant XDEPTH => "xdepth";

use constant MENU => 'menu';
use constant M_QUIT => 'm_quit';
use constant T_QUIT => 't_quit';
use constant M_NETWORK => 'm_network';
use constant T_NETWORK => 't_network';
use constant M_XSERVER => 'm_xserver';
use constant T_XSERVER => 't_xserver';
use constant M_STATUS => 'm_status';
use constant T_STATUS => 't_status';
use constant M_MC => 'm_mc';
use constant T_MC => 't_mc';
use constant M_REBOOT => 'm_reboot';
use constant T_REBOOT => 't_reboot';
use constant M_SHUTDOWN => 'm_shutdown';
use constant T_SHUTDOWN => 't_shutdown';
use constant SHUTDOWN => 'shutdown';
use constant STOPNOTE => 'stopnote';
use constant RAID => 'raid';
use constant RAIDX => 'raidx';
use constant RAIDERROR => 'raiderror';

use constant RAMSTART => 'ramstart';
use constant RAMSTART1 => 'ramstart1';
use constant RAMSTART2 => 'ramstart2';

# constants for ip values
use constant DEFETH => "eth0";
use constant DEFIP => "192.168.0.250";
use constant DEFSM => "255.255.255.0";
use constant DEFGW => "192.168.0.2";
use constant DEFDNS => "192.168.0.2";
# constant for tempfile
use constant TEMPFILE => "/tmp/result";
use constant DEFCD => "/tmp/cd";
use constant DEFHD => "/tmp/hd";
use constant DEFINITRD => "/tmp/initrd";
use constant DEFPART => "/tmp/hd/part";
use constant DEFPART1 => "/tmp/hd/part1";
use constant DEFPART2 => "/tmp/hd/part2";
use constant DEFPART4 => "/tmp/hd/part4";
use constant DEFPART_ROOT => "/";
use constant DEFPART_DATA => "/var/lib/vz";

use constant PART_OS => 4190208; # 4 gb
use constant PART_SWAP => 8380416; # 8 gb


sub title {wrap(@_)} # title of programm
sub messages {wrap(@_)} # hash with messages
sub eth {wrap(@_)} # ethernet device (normally eth0)
sub ip {wrap(@_)} # ip address for installation
sub submask {wrap(@_)} # submask for installation
sub cidr {wrap(@_)} # ip address with cidr notation
sub gw {wrap(@_)} # gateway "
sub dns {wrap(@_)} # dns server "
sub defeth {wrap(@_)} # default eth interface
sub defip {wrap(@_)} # default ip address
sub defsm {wrap(@_)} # default submask
sub defgw {wrap(@_)} # default gateway "
sub defdns {wrap(@_)} # default dsn "
sub tempfile {wrap(@_)} # tempfile to use
sub hdcurrent {wrap(@_)} # current choosen harddisk
sub hdsize {wrap(@_)} # current harddisk size
sub hdmounted {wrap(@_)} # harddisk already mounted
sub cdcurrent {wrap(@_)} # current choosen cdrom drive
sub logit {wrap(@_)} # log all messages during installation process
sub error {wrap(@_)} # set error from a subcall, so you can act according it
sub backupinst {wrap(@_)} # latest installed version
sub goinstpart {wrap(@_)} # the second installed version
sub language {wrap(@_)} # the language we use (en,de..)
sub iso {wrap(@_)} # the iso for the installation
sub auto {wrap(@_)} # 1=automatic installation
sub stickauto {wrap(@_)} # 1=automatic installation from stick/cd
sub keyboard {wrap(@_)} # keyboard definition for auto stock
sub postcopy {wrap(@_)} # copy a program after installation (i.e. cluster)
sub poststart {wrap(@_)} # start a program after installation (i.e. cluster)
sub copyiso {wrap(@_)} # copy iso files after installation
sub copydef {wrap(@_)} # copy vm def after installation
sub copyimg {wrap(@_)} # copy images after installation
sub copyrun {wrap(@_)} # 1=start the installed definition
sub update {wrap(@_)} # directory for update files
sub debuglevel {wrap(@_)} # debuglevel to stop the installation
sub xdriver {wrap(@_)} # xorg driver to use (vesa,intel,ati,nv)
sub xres {wrap(@_)} # xorg resolution to use (1024x768, 1280x1024 etc)
sub xdepth {wrap(@_)} # xorg screen depth (8,15,16,24,32)
sub text {wrap(@_)} # 1=use only ascii lines
sub raidlevel {wrap(@_)} # raid1,raid10
sub raiddevice {wrap(@_)} # /dev/md0
sub raidhds {wrap(@_)} # all hds to use
sub raidcount {wrap(@_)} # number of disks to use (2,4,..)
sub raiddivisor {wrap(@_)} # 1,2,3,4 (2,4,6,8 harddisks
sub part_os {wrap(@_)} # default is 4gb (smaller for raid 10)
sub part_swap {wrap(@_)} # default is 8gb (smaller for raid 10)
sub killit {wrap(@_)} # kill the whole harddisk (fresh new installation)
sub noraid {wrap(@_)} # 1=don't use software raid
sub confload {wrap(@_)} # 1=load the configuration
sub confsave {wrap(@_)} # 1=save the configuration
sub ram {wrap(@_)} # 1=installation in ram (instead of harddisk)
sub ramdata {wrap(@_)} # 1=drive for data partition
sub ramswap {wrap(@_)} # 1=drive for swap partition
sub ramdisk {wrap(@_)} # Use stick (/dev/sdx2 and /dev/sdx3)
sub formathd {wrap(@_)} # 1=format empty harddisk(s) in ram mode
sub eth0 {wrap(@_)} # set mac address for eth0
sub eth1 {wrap(@_)} # set mac address for eth1
sub eth2 {wrap(@_)} # set mac address for eth2
sub eth3 {wrap(@_)} # set mac address for eth3
sub eth4 {wrap(@_)} # set mac address for eth4



sub new {
  my ($class,$lang,$iso,$auto,$text,$killit,$noraid) = @_; # desired language
  my $self = {};
	bless $self,$class;
	$lang = "en" if $lang ne "de";
	$self->language($lang); # set language
	$self->iso($iso); # set (possible iso file)
	$self->auto($auto); # set auto mode (=1)
	$self->text($text); # set simple line mode
	$self->killit($killit); # do a fresh installation
	$self->noraid($noraid); # do a fresh installation
	$self->msg_init; # load messages
	$self->title(TITLE);
	$self->defeth(DEFETH);
	$self->defip(DEFIP); # set default values
	$self->defsm(DEFSM);
	$self->defgw(DEFGW);
	$self->defdns(DEFDNS);
	$self->tempfile(TEMPFILE); # for the results of dialog, we need a temp file
	$self->update(DEFPART4."/update");
	$self->part_os(PART_OS);
	$self->part_swap(PART_SWAP);
	return $self; 
}



# check and prepare for save/load configuration

sub confcheck {
  my ($self,$confload,$confsave) = @_;
	$self->confload($confload);
	$self->confsave($confsave);
  if ($confload==1 || $confsave==1) {
	  $self->auto(1);
	  print "conf mode started, please wait...\n";
  }
}



# check if we are in debug mode

sub debugcheck {
  my ($self,$level) = @_;
	if ($self->debuglevel>0 && $level>0) {
	  if ($self->debuglevel>=$level) {
      system("setterm -msg on");
		  die "stopped by debuglevel $level\n";
		}
	}
}



# read a file and give it back

sub read_file {
  my ($self,$file) = @_;
	my $cont = "";
	if (-e $file) {
	  open(FIN,$file);
		my @lines = <FIN>;
		close(FIN);
		$cont = join("",@lines);
	}
	return $cont;
}



# process cmdline options

sub cmdline {
  my ($self,$opts) = @_;
	my @opts = split(/\s/,$opts);
	foreach my $opt (@opts) {
	  my @vals = split(/\./,$opt);
		my $par = shift @vals;
		my $val = join(".",@vals);
		if ($par eq "auto" || $par eq "stickauto") {
		  $self->stickauto(1);
		} elsif ($par eq "ip") {
		  $self->ip($val);
		} elsif ($par eq "submask") {
		  $self->submask($val);
		} elsif ($par eq "gw") {
		  $self->gw($val);
		} elsif ($par eq "dns") {
		  $self->dns($val);
		} elsif ($par eq "keyboard") {
		  if ($val eq "de_CH" || $val eq "fr_CH" || $val eq "it_CH" ||
			    $val eq "us" || $val eq "it" || $val eq "fr" || $val eq "es") {
        $self->keyboard($val);
			}
		} elsif ($par eq "postcopy") {
      $self->postcopy($val);
		} elsif ($par eq "poststart") {
      $self->poststart($val);
		} elsif ($par eq "lang" || $par eq "language") {
			if ($val eq "de") {
		    $self->language($val);
	      $self->msg_init();
			}
		} elsif ($par eq "copyiso") {
		  $self->copyiso($val);
		} elsif ($par eq "copydef") {
		  $self->copydef($val);
		} elsif ($par eq "copyimg") {
		  $self->copyimg($val);
		} elsif ($par eq "copyrun") {
		  $self->copyrun(1);
		} elsif ($par eq "debuglevel") {
      $self->debuglevel($val);
		} elsif ($par eq "ram") {
      $self->ram(1);
		} elsif ($par eq "ramdata") {
		  $self->ramdata($val);
		} elsif ($par eq "ramswap") {
		  $self->ramswap($val);
		} elsif ($par eq "ramdisk") {
		  $self->ramdisk(1);
		} elsif ($par eq "formathd") {
		  $self->formathd(1);
		} elsif ($par eq "eth0") {
		  $self->eth0($val);
		} elsif ($par eq "eth1") {
		  $self->eth1($val);
		} elsif ($par eq "eth2") {
		  $self->eth2($val);
		} elsif ($par eq "eth3") {
		  $self->eth3($val);
		} elsif ($par eq "eth4") {
		  $self->eth4($val);
		}
	}
}



# process the command line options

sub cmdlinedo {
  my ($self,$to) = @_;
	my $cmd = "";
	if ($self->keyboard ne "") {
	  $self->logadd("activation keyboard");
	  $cmd = "echo '".$self->keyboard()."' >$to/home/archivista/.xkb-layout";
		$self->doit($cmd);
	}
	if ($self->copyiso ne "") {
	  my $from = DEFCD."/".$self->copyiso;
		my $dest = "$to/var/lib/vz/template/iso/".$self->copyiso;
	  if (-e $from && !-e $dest) {
			$cmd = "cp $from $dest";
			$self->doit($cmd);
		}
	}
	if ($self->copyimg ne "") {
	  my $from = DEFCD."/".$self->copydef;
		my $dest = "$to/var/lib/vz/101";
	  if (-e $from && !-e $dest) {
		  $cmd = "mkdir $dest";
			$self->doit($cmd);
			$cmd = "cp $from $dest";
			$self->doit($cmd);
		}
	}
	if ($self->copydef ne "") {
	  my $from = DEFCD."/".$self->copydef;
		my $dest = "$to/etc/qemu-server/101.conf";
	  if (-e $from && !-e $dest) {
			$cmd = "cp $from $dest";
			$self->doit($cmd);
			if ($self->copyrun==1) {
			  my ($def,$ext) = split(/\./,$self->copydef);
			  $cmd = "qm start $def";
				$self->doit($cmd);
			}
		}
	}
	if ($self->postcopy ne "") {
	  my $from = DEFCD."/".$self->postcopy;
	  if (-e $from) {
			$cmd = "cp -f $from $to";
			$self->doit($cmd);
			$cmd = "chmod a+x $to/".$self->postcopy;
			$self->doit($cmd);
		}
	}
	if ($self->poststart ne "") {
	  my $from1 = "$to/".$self->poststart;
	  my $from2 = DEFCD."/".$self->poststart;
		if (!-e $from1 && -e $from2) {
			$cmd = "cp -f $from2 $to";
			$self->doit($cmd);
			$cmd = "chmod a+x $to/".$self->poststart;
			$self->doit($cmd);
		}
	  if (-e $from1) {
      $self->doit($from1);
		}
  }
}



# read the network values

sub read_ipvalues {
  my ($self,$set) = @_;
	my $file = "/etc/network/interfaces";
	my $cont = $self->read_file($file);
	$cont =~ /(bridge_ports)(\s?)(.*)/;
	$self->defeth($3) if $1 eq "bridge_ports" && $3 ne "";
	$cont =~ /(address)(\s?)(.*)/;
	$self->defip($3) if $1 eq "address" && $3 ne "";
	$cont =~ /(netmask)(\s?)(.*)/;
	$self->defsm($3) if $1 eq "netmask" && $3 ne "";
	$cont =~ /(gateway)(\s?)(.*)/;
	$self->defgw($3) if $1 eq "gateway" && $3 ne "";
	$file = "/etc/resolv.conf";
	$cont = $self->read_file($file);
	$cont =~ /(nameserver)(\s?)(.*)/;
	$self->defdns($3) if $1 eq "nameserver" && $3 ne "";
	if ($set==1) {
	  my $cidr = &mask2cidr($self->defsm);
	  $self->cidr($cidr);
		$self->ip($self->defip);
		$self->gw($self->defgw);
		$self->submask($self->defsm);
		$self->dns($self->defdns);
	}
}



# save changed ip values and restart intervace

sub save_ipvalues {
  my ($self,$path) = @_;
	if ($self->cidr ne "") { # save the new values
	  $self->ip_set($path);
	  $self->doit("/etc/init.d/networking restart");
	}
}



# set ip,cidr and submask from ipcidr

sub set_ipcidr {
  my ($self,$ipcidr) = @_;
	my ($ip1,$cidr1) = split(/\//,$ipcidr);
	if ($ip1 ne "" && $cidr1 ne "") {
	  $self->ip($ip1);
		$cidr1 = "/".$cidr1;
	  my $val = &cidr2mask($cidr1);
		$self->submask($val);
		$self->cidr($cidr1);
	}
}



# save the network values

sub ip_set {
  my ($self,$to) = @_;
	my $eth = $self->eth();
	$eth = "eth0" if $eth eq "";
	my $cont = "auto lo\n".
	         "iface lo inet loopback\n\n".
					 "auto vmbr0\n".
					 "iface vmbr0 inet static\n".
	         "  address ".$self->ip."\n".
	         "  netmask ".$self->submask."\n".
					 "  gateway ".$self->gw."\n".
	         "  bridge_ports $eth\n".
					 "  bridge_stp off\n".
					 "  bridge_fd 0\n";
	$self->doit("echo \"$cont\" >$to/etc/network/interfaces");
	$cont = "nameserver ".$self->dns."\n";
	$self->doit("echo \"$cont\" >$to/etc/resolv.conf");
	my $lm = $self->ip();
	my @lms = split(/\./,$lm);
	my $last = pop @lms;
	my $name = "avbox".$last;
	$self->doit("echo \"$name\" >$to/etc/hostname");
}



# print out a message accorind an id

sub msg {
  my ($self,$id) = @_;
	return ${$self->messages}{$id};
}



# add empty chars arround text (needed for dialog)

sub msgplus {
  my ($self,$id) = @_;
	my $msg = ${$self->messages}{$id};
	return $self->quote($msg);
}



# add quotes arround text

sub quote {
  my ($self,$msg) = @_;
	return ' "'.$msg.'" ';
}



# progress bar (send it to background, so we can process 

sub gauge {
  my ($self,$c,$msg) = @_;
	if ($self->auto==0) {
	  my $msg1 = $self->msgplus($msg);
    system($self->formtitle."--guage $msg1 8 60 $c &");
	}
	$self->debugcheck($c);
}



# load the desired language file

sub msg_init {
  my ($self) = @_;
	my %msgi = {};
	my $file = "./mess_".$self->language.".txt";
	open(FIN,$file);
	my @lines = <FIN>;
	close(FIN);
	foreach my $line (@lines) {
	  chomp $line;
		next if $line eq "";
	  my @parts = split("=",$line);
		my $id = shift @parts;
    my $msg = join("=",@parts);
		$msgi{$id}=$msg;
	}
	$self->messages(\%msgi);
}



# find out what harddisk we have, please take note that for this moment
# we only can handle first harddisk

sub allharddisks {
  my ($self) = @_;
  my $res = ();
  my $count = 0;
  my @usbdrives = ();
  my $usb = `ls -ls /dev/disk/by-id/usb* 2>/dev/null | grep 'sd' 2>/dev/null`;
  my (@lines) = split(/\n/,$usb);
  foreach my $line (@lines) {
    my @parts = split(/\//,$line);
    my $drive = pop @parts;
    next if $drive =~ /([0-9])$/;
    chomp $drive;
    push @usbdrives,"/sys/block/$drive" if $drive ne "";
  }
  my $pfiles = $self->getdirs("/sys/block");
  foreach my $bd (@$pfiles) {
	  next if $bd =~ m|^/sys/block/ram\d+$|;
	  next if $bd =~ m|^/sys/block/loop\d+$|;
	  next if $bd =~ m|^/sys/block/md\d+$|;
	  next if $bd =~ m|^/sys/block/dm-.*$|;
	  next if $bd =~ m|^/sys/block/fd\d+$|;
	  next if $bd =~ m|^/sys/block/sr\d+$|;
	  my $dev = `cat '$bd/dev' 2>/dev/null`;
	  chomp $dev;
	  next if !$dev;
	  my $isusb = 0; # check if it is usb stick (don't use it)
	  foreach my $usbdrive (@usbdrives) {
	    $isusb=1 if $bd eq $usbdrive;
	  }
	  next if $isusb==1;
	  my $removable = `cat /$bd/removable 2>/dev/null`;
	  next if $removable == 1;
	  # udev does not set DEVTYPE correctly, so we need to read that 
	  # from uevent
	  my $info = `cat $bd/uevent 2>/dev/null`;
	  next if !$info || $info !~ m/^DEVTYPE=disk$/m;
	  $info = `udevadm info --path $bd --query all 2>/dev/null`;
	  next if !$info;
	  next if $info =~ m/^E: ID_CDROM/m;
	  my ($name) = $info =~ m/^N: (\S+)$/m;
	  if ($name) { 
	    my $real_name = "/dev/$name";
	    my $size = `cat '$bd/size' 2>/dev/null`; # calculate size in gbyte
	    chomp $size;
	    $size = undef if $size !~ m/^\d+$/;
			next if $size <=0;
			$size = int($size/2);
	    my $model = `cat '$bd/device/model' 2>/dev/null`;
			$model =~ s/^\s+//;
	    $model =~ s/\s+$//;
	    if (length ($model) > 30) {
		    $model = substr ($model, 0, 30);
	    }
	    push @$res, [$count++, $real_name, $size, $model];
	  } else {
	    print STDERR "ERROR: unable to map device $dev ($bd)\n";
	  }
  }
  return $res;
}



# get all ddirectories on one folder level

sub getdirs {
  my ($self,$dir) = @_;
	my @outfiles;
	opendir(FIN,$dir);
	my @files = readdir(FIN);
	closedir(FIN);
	foreach (@files) {
	  my $file = $_;
	  next if $file eq ".";
		next if $file eq "..";
		chomp $file;
		push @outfiles, "$dir/$file";
	}
	@outfiles = sort @outfiles;
	return \@outfiles;
}



# get all devices from

sub getdevices {
  my ($self,$pattern,$pfiles) = @_;
  my $cmd = "cd /sys/block;find -name '$pattern*'";
  my $res = `$cmd 2>/dev/null`;
	my @files = split("\n",$res);
	foreach my $file (@files) {
	  my $file2 = $file;
	  $file =~ s/^(.*)(\/)(.*\d+?)$/$3/;
		if ($file2 ne $file && $file ne "") {
		  $file2 =~ s/^(\.\/?){1,1}($pattern?)(\/?)(.*)$/$2/;
			if ($2 eq $pattern) {
	      push @$pfiles,"/dev/$file";
			}
		}
	}
}



# any result of a dialog box goes to the temp directory, so get the result back

sub results {
  my ($self) = shift;
  open(FIN,TEMPFILE);
  my @lines = <FIN>;
	my $c=0;
	foreach my $line (@lines) {
	  chomp $line;
	  $lines[$c] = $line;
	  $c++;
	}
  return @lines;
}



# set the back title of the program

sub backtitle {
  my ($self) = @_;
  return " --backtitle".$self->quote($self->title);
}



# send out title of a dialog box and the labels for ok/cancel/yes/now

sub formtitle {
  my ($self,$defaultno) = @_;
	my $opt = "";
	$opt .= " --defaultno " if $defaultno==DEFAULTNO;
	$opt .= "--ascii-lines " if $self->text()==1;
  return "dialog ".$opt.
	       "--ok-label".$self->msgplus(OK).
	       "--cancel-label".$self->msgplus(CANCEL).
	       "--yes-label".$self->msgplus(YES).
	       "--no-label".$self->msgplus(NO).$self->backtitle();
}



# check if we already have an installation

sub check_update {
  my ($self) = @_;
	if ($self->hdcurrent ne "" && $self->hdmounted==0 && $self->killit==0) {
    $self->mount_parts(); # mount partitions, so we can check it
		if ($self->hdmounted==1) {
		  if ($self->iso eq "") {
		    my $part1 = DEFPART1."/install.log";
		    my $part2 = DEFPART2."/install.log";
		    if (-e $part1) {
			    $self->backupinst(1);
				  $self->goinstpart(2); # installation goes to second partition
			  } elsif (-e $part2) {
			    $self->backupinst(2);
			  }
			}
			if ($self->confload==1) {
			  if ($self->goinstpart==2) {
				  $self->goinstpart(1);
					$self->backupinst(1);
				} else {
				  $self->goinstpart(2);
					$self->backupinst(2);
				}
       	my $dmsfrom = "/var/lib/vz/datadms";
	      my $dmsto = DEFPART4."/datadms";
	      my $cmd = "";
	      $self->update_restore($dmsfrom,$dmsto);
		    $self->writelog("/log");
				print "configuration loaded\n";
				exit 0;
      } else {
			  $self->update_backup(); # save the values from the current installation
				if ($self->confsave==1) {
		      $self->writelog("/log");
				  print "configuration saved\n";
					exit 0;
				}
			}
		}
		$self->unmount(); # unmount partions, otherwise we don't can format it
	}
}



# save everything that is intersting for us

sub update_backup {
  my ($self) = @_;
	my $updir = $self->update;
	$self->doit("rm -rf $updir") if -e $updir;
	mkdir $updir if !-e $updir;
	if ($self->backupinst>0) {
	  $self->logadd("save configuration");
	  my $part = DEFPART.$self->backupinst;
		my $cmd = "cp -p $part/etc/network/interfaces $updir";
		$self->doit($cmd);
		$cmd = "cp -p $part/etc/modprobe.d/arch/x86_64 $updir";
		$self->doit($cmd);
		foreach my $file ("resolv.conf","passwd","shadow","groups",
		                  "exports","hostname","mactab","mactemp") {
		  $cmd = "cp -p $part/etc/$file $updir";
		  $self->doit($cmd);
		}
		$cmd = "cp -Rp $part/etc/qemu-server $updir";
		$self->doit($cmd);
		$cmd = "cp -Rp $part/etc/pve $updir";
		$self->doit($cmd);
		$cmd = "cp -Rp $part/root/.ssh $updir";
		$self->doit($cmd);
		$self->update_backup_dms($part,$updir);
  }
}



# save values we use for dms system

sub update_backup_dms {
  my ($self,$part,$update) = @_;
  my $code = "$part/home/cvs/archivista";
	my $home = "$part/home/archivista";
	my $cmd = "";
	my @global = ("$code/apcl/Archivista/Config.pm",
                "$code/webclient/perl/inc/Global.pm",
	              "$code/erp/config_db.php",
                "$part/var/spool/cron/crontabs/root",
                "$home/.gnupg","$home/.xkb-layout",
								"$part/etc/mysql/my.cnf",
								"$part/etc/vsftpd.conf",
								"$part/etc/vsftpd.user_list",
								"$part/etc/shells",
								"$part/etc/default/apcupsd",
								"$part/etc/apcupsd/apcupsd.conf",
							 );
	foreach (@global) {
	  $cmd = "cp -pf $_ $update";
		$self->doit($cmd);
	}
	mkdir "$update/etc" if !-e "$update/etc";
	my @webconfig = `ls $part/etc/*webconfig.conf 2>/dev/null`;
	foreach (@webconfig) {
	  my $file = $_;
	  chomp $file;
	  $cmd = "cp -pf $file $update/etc";
		$self->doit($cmd);
	}
	my @conf = ("erp.conf","lang.conf","processlocal.conf",
	            "ftp-process.conf","nologinext.conf","localtime",
						  "crontab","vnc.conf","sphinx.conf","mail.conf","sshd.conf",
							"net-backup.conf","rsync-backup.conf","usb-backup.conf",
							"inetd.conf","av-button.conf","xorg.conf","https.conf",
							"drbd.conf","drbdcheck.conf");
	foreach (@conf) {
	  $cmd = "cp -pf $part/etc/$_ $update/etc";
		$self->doit($cmd);
	}
  my @ocr = ("$home/.wine/drive_c/Programs/Av5e","$part/etc/cups",
             "$home/.wine/drive_c/Programs/av41fr5");
	foreach (@ocr) {
	  $cmd = "cp -Rpf $_ $update";
		$self->doit($cmd);
	}
}



# restore the desired values

sub update_restore {
  my ($self,$dmsfrom,$dmsto) = @_;
	my $update = $self->update;
	$self->logadd("restore configuration");
  my $part = DEFPART.$self->goinstpart;
	my $cmd = "cp -pf $update/interfaces $part/etc/network/interfaces";
	$self->doit($cmd);
  $cmd = "cp -p $update/x86_64 $part/etc/modprobe.d/arch";
	$self->doit($cmd);
	my @files = ("resolv.conf","passwd","shadow","groups",
	             "exports","hostname","mactab","mactemp");
	if (-e "$dmsfrom" && !-e "$dmsto") {
	  $self->msgok($self->msg(AVBOX));
    $self->gauge(95,WAIT);
		@files = ("resolv.conf","hostname");
	}
	foreach my $file (@files) {
	  $cmd = "cp -pf $update/$file $part/etc/$file";
	  $self->doit($cmd);
	}
	$cmd = "cp -Rpf $update/qemu-server $part/etc";
	$self->doit($cmd);
	$cmd = "cp -Rpf $update/pve $part/etc";
	$self->doit($cmd);
	$cmd = "cp -Rp $update/.ssh $part/root";
	$self->doit($cmd);
	$cmd = "cp -Rp $update/vsftpd.conf $part/etc";
	$self->doit($cmd);
	$cmd = "cp -Rp $update/vsftpd.user_list $part/etc";
	$self->doit($cmd);
	$cmd = "cp -Rp $update/apcupsd $part/etc/default";
	$self->doit($cmd);
	$cmd = "cp -Rp $update/apcupsd.conf $part/etc/apcupsd";
	$self->doit($cmd);
	$cmd = "cp -Rp $update/shells $part/etc";
	$self->doit($cmd);
	my $partold = DEFPART.$self->backupinst;
	if (-s "$update/etc/drbdcheck.conf") {
	  my $full = $self->read_file("$part/etc/fstab");
		$full =~ s/(sda4)/drbd0/;
		$full =~ s/(md4)/drbd0/;
		$full =~ s/(vda4)/drbd0/;
		open(FOUT,">$part/etc/fstab");
		print FOUT $full;
		close(FOUT);
		foreach my $nr (2,3,4,5) {
		  system("cp -rp $partold/etc/rc$nr.d/S14drbd $part/etc/rc$nr.d");
		  system("cp -rp $partold/etc/rc$nr.d/S15drbdcheck $part/etc/rc$nr.d");
		}
	} elsif ($self->hdcurrent eq '/dev/vda') {
	  my $full = $self->read_file("$part/etc/fstab");
		$full =~ s/(\/dev\/sda)/\/dev\/vda/;
		open(FOUT,">$part/etc/fstab");
		print FOUT $full;
		close(FOUT);
	}
	$self->update_restore_dms($part,$update); # dms specific values
	$cmd = "rm -f $partold/install.log"; # remove log from older version
	$self->doit($cmd);
  my $grub = "$partold/boot/grub/menu.lst";
  if (-e $grub) { # adjust grub (later booting from harddisk)
	  my $full = $self->read_file($grub);
    $full =~ /(.*?)(\n\n)(title)(.*?)(\n\n)(title)(.*)/s;
	  my $current = "$3$4";
	  my $partnr = $self->backupinst;
		$partnr=$partnr-1;
	  $current =~ s/(.*?)(\(hd)([0-9])(,)([0-9])(.*)/$1$2$3$4$partnr$6/;
    $current =~ s/(title)(.*?)(\n)/$1$2 (old)$3/;
		my $oc = $current;
		$self->logadd($current);
    $grub = "$part/boot/grub/menu.lst";
    if (-e $grub) { # add older version too to menu.lst (grub)
		  $full = $self->read_file($grub);
      $full =~ /(.*?)(\n\n)(title)(.*?)(\n\n)(title)(.*)/s;
	    $current = "$3$4";
	    $partnr = $self->goinstpart;
			$partnr = $partnr-1;
	    $current =~ s/(.*?)(\(hd)([0-9])(,)([0-9])(.*)/$1$2$3$4$partnr$6/;
			$partnr = $partnr+1;
			$current =~ s/(sda)([0-9]{1,1})/$1$partnr/;
			$current =~ s/(md)([0-9]{1,1})/$1$partnr/;
			$current =~ s/(vda)([0]{1,1})/$1$partnr/;
		  my $nc = $current;
			$self->logadd($current);
			my $t = "title";
      $full=~s/(.*?)(\n\n)($t)(.*?)(\n\n)($t)(.*)/$1$2$nc\n\n$oc\n\n$t$7/s;
			$self->logadd($full);
			open(FOUT,">$grub");
			print FOUT $full;
			close(FOUT);
		}
	}
}



# restore values we use for dms system

sub update_restore_dms {
  my ($self,$part,$update) = @_;
  my $code = "$part/home/cvs/archivista";
	my $home = "$part/home/archivista";
	my $cmd = "cp -pf $update/Config.pm $code/apcl/Archivista";
	$self->doit($cmd);
	$cmd = "cp -pf $update/Global.pm $code/webclient/perl/inc";
	$self->doit($cmd);
	$cmd = "cp -pf $update/config_db.php $code/erp";
	$self->doit($cmd);
	$cmd = "cp -pf $update/root $part/var/spool/cron/crontabs";
	$self->doit($cmd);
	$cmd = "cp -pf $update/.gnupg $home";
	$self->doit($cmd);
	$cmd = "cp -pf $update/.xkb-layout $home";
	$self->doit($cmd);
	$cmd = "cp -pf $update/my.cnf $part/etc/mysql";
	$self->doit($cmd);
	$cmd = "cp -pf $update/etc/* $part/etc";
	$self->doit($cmd);
  $cmd = "cp -Rpf $update/Av5e $home/.wine/drive_c/Programs";
	$self->doit($cmd);
	$cmd = "cp -Rpf $update/cups $part/etc";
	$self->doit($cmd);
  $cmd = "cp -Rpf $update/av41fr5 $home/.wine/drive_c/Programs";
	$self->doit($cmd);
}



# change sda to md in menu.lst

sub grub_raiddrive {
  my ($self) = @_;
	if ($self->raiddevice ne "") {
    my $part = DEFPART.$self->goinstpart;
    my $grub = "$part/boot/grub/menu.lst";
    if (-e $grub) {
	    my $full = $self->read_file($grub);
		  $full =~ s/(sda)([0-9]{1,1})/md$2/;
		  open(FOUT,">$grub");
		  print FOUT $full;
		  close(FOUT);
		}
	}
}



# change sda to vda in menu.lst

sub grub_virtiodrive {
  my ($self) = @_;
	if ($self->hdcurrent eq '/dev/vda') {
    my $part = DEFPART.$self->goinstpart;
    my $grub = "$part/boot/grub/menu.lst";
    if (-e $grub) {
	    my $full = $self->read_file($grub);
		  $full =~ s/(sda)([0-9]{1,1})/vda$2/;
		  open(FOUT,">$grub");
		  print FOUT $full;
		  close(FOUT);
		}
	}
}



# install the installer to the current partition

sub install_installer {
  my ($self) = @_;
  my $from = "";
	if ($self->iso ne "") {
		$from = DEFINITRD;
	  my $cmd = "mkdir $from";
		$self->doit($cmd);
	  $cmd = "cd $from;zcat ".DEFCD."/initrd.img 2>/dev/null | cpio -iv";
		$self->doit($cmd);
	}
  my $part = DEFPART.$self->goinstpart;
	my $cmd = "cp -rp $from/etc/perl $part/etc";
	$self->doit($cmd);
	$cmd = "cp -rp $from/install.pl $part/etc/perl";
  $self->doit($cmd);
	$cmd = "chmod u+x $part/etc/perl/install.pl";
  $self->doit($cmd);
	$cmd = "cp -rp $from/unsquash $part/etc/perl";
	$self->doit($cmd);
	$cmd = "cp -rp $from/mess* $part/etc/perl";
  $self->doit($cmd);
  if (!-e "$part/usr/bin/dialog") {
	  $cmd = "cp -rp $from/usr/bin/dialog $part/usr/bin";
	  $self->doit($cmd);
	  $cmd = "cp -rp $from/lib/libncurs* $part/lib";
	  $self->doit($cmd);
	}
	if (!-e "$part/usr/bin/unsquashfs") {
    $cmd = "cp -rp $from/usr/bin/unsquashfs $part/usr/bin";
	  $self->doit($cmd);
	}
	if ($self->iso ne "") {
	  $cmd = "rm -rf ".DEFINITRD;
	  $self->doit($cmd);
	}
  $cmd = "cp -f ".DEFCD."/boot.msg $part/boot";
	$self->doit($cmd);
}



# main menu (if called interactive) 

sub menu {
  my ($self) = @_;
	if ($self->stickauto==0) {
	  my $action = "";
		while ($action ne $self->msg(M_QUIT)) {
      my $cmd = $self->formtitle."--menu".$self->msgplus(MENU)."16 76 7".
		    $self->msgplus(M_NETWORK).$self->msgplus(T_NETWORK).
		    $self->msgplus(M_XSERVER).$self->msgplus(T_XSERVER).
		    $self->msgplus(M_STATUS).$self->msgplus(T_STATUS).
		    $self->msgplus(M_MC).$self->msgplus(T_MC).
		    $self->msgplus(M_REBOOT).$self->msgplus(T_REBOOT).
		    $self->msgplus(M_SHUTDOWN).$self->msgplus(T_SHUTDOWN).
		    $self->msgplus(M_QUIT).$self->msgplus(T_QUIT).
		    " 2>".$self->tempfile();
      system("$cmd");
	    my ($choose) = $self->results();
			chomp $choose;
			if ($choose eq $self->msg(M_QUIT) || $choose eq "") {
			  $action = $self->msg(M_QUIT);
			} elsif ($choose eq $self->msg(M_NETWORK)) {
        $self->read_ipvalues(); # read the values for editing
        $self->choose_networking(); # ask for ip address 
	      $self->save_ipvalues(""); 
			} elsif ($choose eq $self->msg(M_XSERVER)) {
        $self->choose_xorg();
      } elsif ($choose eq $self->msg(M_MC)) {
        $cmd = "mc";
				system($cmd);
      } elsif ($choose eq $self->msg(M_STATUS)) {
        $cmd = "/home/archivista/status.sh >/tmp/status -webconfig";
				system("$cmd >>".$self->tempfile());
        my $cmd = $self->formtitle."--textbox ".
			            $self->quote($self->tempfile)." 16 76";
			  system($cmd);
      } elsif ($choose eq $self->msg(M_REBOOT)) {
			  $self->msgok($self->msg(STOPNOTE));
	      my $msg = $self->msg(END2);
	      $self->doit("reboot") if $self->msgbox($msg,1,1);
			} elsif ($choose eq $self->msg(M_SHUTDOWN)) {
			  $self->msgok($self->msg(STOPNOTE));
	      my $msg = $self->msg(SHUTDOWN);
	      $self->doit("poweroff") if $self->msgbox($msg,1,1);
			}
		}
	}
}



# choose xorg server

sub choose_xorg {
  my ($self) = @_;
	if ($self->stickauto==0) {
	  my $cont = $self->read_file("/etc/xorg.conf");
		my ($xdriver,$xres,$xdepth) = split(/\n/,$cont);
		$xdriver = "vesa" if $xdriver eq "";
		$xres = "1024x768" if $xres eq "";
		$xdepth = 16 if $xdepth eq "";
		$self->xdriver($xdriver);
		$self->xres($xres);
		$self->xdepth($xdepth);
    my $cmd = $self->formtitle."--form".$self->msgplus(XORG)."16 70 8".
		  $self->msgplus(XDRIVER)."2 4".$self->quote($self->xdriver)."2 50 12 0".
		  $self->msgplus(XRES)."4 4".$self->quote($self->xres)."4 50 12 0".
		  $self->msgplus(XDEPTH)."6 4".$self->quote($self->xdepth)."6 50 12 0".
		  " 2>".$self->tempfile();
    system("$cmd");
	  ($xdriver,$xres,$xdepth) = $self->results();
		$self->xdriver($xdriver),
		$self->xres($xres);
		$self->xdepth($xdepth);
		$cmd = "echo \"$xdriver\n$xres\n$xdepth\" >/etc/xorg.conf";
		$self->doit($cmd);
	}
}



# choose the network settings (at this moment, no ip check is done)

sub choose_networking {
  my ($self) = @_;
	if ($self->stickauto==1 && $self->ip ne "" && $self->submask ne "" &&
	    $self->gw ne "" && $self->dns ne "") {
    my $cidr = &mask2cidr($self->submask);
	  $self->cidr($cidr);
	} else {
    my $cmd = $self->formtitle."--form".$self->msgplus(NETWORK)."17 70 10".
		  $self->msgplus(ETH)."2 4".$self->quote($self->defeth)."2 25 20 0".
		  $self->msgplus(IP)."4 4".$self->quote($self->defip)."4 25 20 0".
		  $self->msgplus(SM)."6 4".$self->quote($self->defsm)."6 25 20 0".
		  $self->msgplus(GW)."8 4".$self->quote($self->defgw)."8 25 20 0".
		  $self->msgplus(DNS)."10 4".$self->quote($self->defdns)."10 25 20 0".
		  " 2>".$self->tempfile();
    system("$cmd");
	  my ($eth,$ip,$sm,$gw,$dns) = $self->results();
    my $cidr = &mask2cidr($sm);
		$self->eth($eth);
	  $self->ip($ip);
	  $self->submask($sm);
	  $self->cidr($cidr);
	  $self->gw($gw);
	  $self->dns($dns);
		my $fname = DEFCD."/hwadr";
		if (-e $fname) {
		  my $found = 0;
	    my $cont = $self->read_file($fname);
			my @lines = split(/\n/,$cont);
			foreach my $check (@lines) {
			  my ($adr,$type) = split(';',$check);
				my $res = `ifconfig $eth`;
				if ($type==0 || $type==1) {
				  $res =~ /($adr)/;
				  if ($1 eq $adr) {
					  $found=1;
						last;
					}
				}
			}
			
		  if ($found==0) {
		    $self->cidr("");
		    $self->hdcurrent("");
		  }
		}
	}
}



# choose a harddisk for a new (fresh installation), at this moment, only first
# hard disk works

sub choose_harddisk {
  my ($self,$raidinstall) = @_;
	my $pdrives = $self->allharddisks();
	my $hdroot = $self->check_root;
  my $cmd = $self->formtitle."--checklist".$self->msgplus(HARDDISK)."15 70 8";
  my $choose = "on";
	my $choosenr = 0;
  my %hdsize;
	my $c=0;
  foreach my $pdrv (@$pdrives) {
    my $size = int ($$pdrv[2]/1024/1024);
	  $size = "$size GByte";
		if ($hdroot ne "") {
		  $choose = "off";
			if ($hdroot eq $$pdrv[1]) {
		    $choose = "on";
				$choosenr = $c;
			}
		}
    $cmd .= " ".$$pdrv[1].$self->quote("$$pdrv[3] - $size").$choose;
	  $hdsize{$$pdrv[1]}=$$pdrv[2];
		$choose = "off";
		$c++;
	}
	$cmd .= " 2>".$self->tempfile();
	my $hd = $$pdrives[$choosenr][1]; # choose first hard disk (default)
	if ($self->auto==0 && $self->iso eq "" && $self->stickauto==0) {
	  my $res=system($cmd);
		$self->confirm($res);
	  ($hd) = $self->results();
		$hd =~ s/\"//g;
	}
	my $hd1 = $self->choose_raid($hd,\%hdsize,$raidinstall);
  $self->hdcurrent($hd1);
	$self->hdsize($hdsize{$hd1});
}



# check if we have a raid (and apply it

sub choose_raid {
  my ($self,$hd,$phdsize,$raidinstall) = @_;
	my @hds = split(/\s/,$hd);
	@hds = sort @hds;
  $self->init_raid();
	my $hdraid = $self->check_raid();
	if ($hds[1] ne "" && $hdraid eq "") {
	  my $count = @hds;
	  if ($raidinstall eq "") {
	    my $msg = $self->msg(RAID);
	    if ($self->msgbox($msg,1,1)) {
	      if ($count % 2 == 1) {
     	    $msg = $self->msg(RAIDX);
	        if ($self->msgbox($msg,1,1)) {
				    pop @hds;
	          $count = @hds;
				  }
			  }
			  if ($count==2) {
			    $self->raidlevel("raid1");
			  } elsif ($count % 2 == 0) {
			    $self->raidlevel("raid10");
			  } else {
	        # error
			    $self->msgok($self->msg(RAIDERROR));
				  die;
        }
			}
		} else {
		  $self->raidlevel("raid1");
		  if ($raidinstall eq "raid0") {
		    $self->raidlevel("raid0");
			} elsif ($raidinstall eq "raid5") {
		    $self->raidlevel("raid5") if $hds[2] ne "";
			} elsif ($raidinstall eq "raid6") {
		    $self->raidlevel("raid6") if $hds[3] ne "";
			} elsif ($raidinstall eq "raid10") {
		    $self->raidlevel("raid10") if $hds[3] ne "";
			}
			if ($raidinstall eq "raid1" || $raidinstall eq "raid6" ||
			    $raidinstall eq "raid10") {
	      if ($count % 2 == 1) {
			    pop @hds;
	        $count = @hds;
			  }
			}
		}
		my $hd1 = join(" ",@hds);
		$self->raidhds($hd1);
		$self->raiddevice("/dev/md");
		$self->raidcount($count);
		my $size = $$phdsize{$hds[0]};
		$$phdsize{$self->raiddevice}=$size;
		$hd = $self->raiddevice;
	}
	$hd = $hdraid if $hdraid ne "";
	return $hd;
}  



sub check_raid {
  my ($self) = @_;
	my $hdraid = "";  # we check if the raid exists, if so dont ask for raid
	my $file = "/etc/mdadm/mdadm.conf";
	my $cmd = "mdadm --examine --scan >$file";
	$self->doit($cmd);
	my $cont = $self->read_file($file);
	$cont = "" if $self->killit==1;
	$cont = "" if $self->noraid==1;
	if ($cont ne "") {
	  $cmd = "mdadm --assemble /dev/md1";
	  $self->doit($cmd);
	  $cmd = "mdadm --assemble /dev/md2";
	  $self->doit($cmd);
	  $cmd = "mdadm --assemble /dev/md3";
	  $self->doit($cmd);
	  $cmd = "mdadm --assemble /dev/md4";
	  $self->doit($cmd);
	  $cmd = "mdadm --assemble /dev/md8";
	  $self->doit($cmd);
		$hdraid = "/dev/md";
		$self->raiddevice($hdraid);
	}
	return $hdraid;
}



sub init_raid {
   my ($self) = @_;
   my $cmd = "modprobe -q md";
   $self->doit($cmd);
   $cmd = "modprobe -q linear";
   $self->doit($cmd);
   $cmd = "modprobe -q multipath";
   $self->doit($cmd);
   $cmd = "modprobe -q raid0";
   $self->doit($cmd);
   $cmd = "modprobe -q raid1";
   $self->doit($cmd);
   $cmd = "modprobe -q raid456";
   $self->doit($cmd);
   $cmd = "modprobe -q raid6_pq";
   $self->doit($cmd);
   $cmd = "modprobe -q raid10";
   $self->doit($cmd);
}



# Confirm pressing esc key

sub confirm {
  my ($self,$res) = @_;
	my $msg = $self->msg(CONFIRM);
  $self->msgbox($msg,DEFAULTNO) if $res !=0;
}



# welcome message and language choosser

sub hello {
  my ($self) = @_;
	if ($self->auto==0 && $self->stickauto==0) {
	  my $msg = $self->msg(LANGUAGE)."\n\n".
	            $self->msg(HELLO1)." ".$self->msg(HELLO2);
    my $cmd = $self->formtitle."--radiolist".$self->quote($msg)."15 60 8";
	  my $choose = "on";
	  $choose = "off" if $self->language ne "en";
	  $cmd .= " "."en".$self->msgplus(LANG_EN).$choose;
	  $choose = "on";
	  $choose = "off" if $self->language ne "de";
	  $cmd .= " "."de".$self->msgplus(LANG_DE).$choose;
	  $cmd .= " 2>".$self->tempfile();
	  my $res=system($cmd);
		$self->confirm($res);
	  my ($lang) = $self->results();
	  if ($lang ne $self->language) { # reload langueages strings if needed
	    $self->language($lang);
	    $self->msg_init();
		}
	}
	if (-e "/udev") {
    $self->gauge(0,WAIT);
	  $self->doit("/udev"); # have a look for the installation media
	}
  $self->gauge(5,FINDCD);
  if ($self->confload==0 && $self->confsave==0) {
	  $self->mountcd(); # mount the installation media
	}
}



# display an ok messgae

sub msgok {
  my ($self,$mess,$big) = @_;
	my $x = 50;
	my $y = 8;
	if ($big==1) {
	  $x = 74;
		$y = 14;
	}
  my $msg = "dialog".$self->backtitle()."--nocancel --msgbox ".
	          $self->quote($mess)." $y $x";
	my $res=system($msg);
}



# print out message box (yes/no question)

sub msgbox {
  my ($self,$message,$defaultno,$nostop) = @_;
	my $yes = 0;
	if ($self->auto==0 && $self->stickauto==0) {
    my $cmd = $self->formtitle($defaultno).
		          "--yesno".$self->quote($message)."9 52";
    my $res = system($cmd);
		my $error = 0;
		if ($defaultno==DEFAULTNO) {
		  $error = 1 if $res==0;
		} else {
		  $error = $res; 
		}
	  if ($error!=0 && $nostop==0) {
	    die "Installation stopped. Type in 'reboot' for restartign system";
	  }
		$yes = 1 if $res==0;
	}
	return $yes;
}



# mount the first removable device (normally cd/dvd)

sub mountcd {
  my ($self) = @_;
	$self->doit("mkdir ".DEFCD) if !-d DEFCD;
	$self->doit("umount ".DEFCD." 2>/dev/null");
	my @files = ();
	my $ctotal = 0;
	if ($self->iso eq "") {
	  $self->getdevices("scd",\@files);
	  $self->getdevices("sd",\@files);
	  $self->getdevices("hd",\@files);
	  $self->getdevices("sr",\@files);
	  $ctotal = @files -1;
	} else {
	  $files[0]="-o loop ".$self->iso;
	}
	my $maxc=10;
	for (my $c=1;$c<=$maxc;$c++) {
	  for (my $c1=$ctotal;$c1>=0;$c1--) {
		  my $cdrom = $files[$c1];
      my $res1=system("mount $cdrom ".DEFCD." 2>/dev/null");
			if ($res1==0) {
			  my $file1 = DEFCD."/system.os";
				my $file2 = DEFCD."/boot.msg";
			  if (-e $file1 && -e $file2) {
			    $self->cdcurrent($cdrom);
			    $c=$maxc;
				  last;
			  } else {
          $self->doit("umount $cdrom 2>/dev/null");
			  }
			}
    }
		if ($self->cdcurrent eq "") { # drive not yet found, so wait
			sleep 2;
		}
	}
}



# installation / update job

sub install {
  my ($self) = @_;
  $self->check_mounted();
	# installation is only done if the desired harddisk is not mounted
	if ($self->hdmounted()==0) {
	  my $msg = $self->msg(GO1)."\n\n".$self->msg(GO2);
	  if ($self->backupinst>0) {
	    $msg = $self->msg(UP1)."\n\n".$self->msg(UP2);
		}
	  $self->msgbox($msg);
    $self->gauge(15,FORMATHD);
		if ($self->backupinst==0) { 
		  # it is a fresh installation
      $self->format_hd(); # format the whole harddisk
		} else {
	    my $format = "ext3"; # format only system partition
		  if ($self->backupinst==2) {
        $self->gauge(25,PARTHD1);
        $self->format_part(1,$format);
			} else {
        $self->gauge(30,PARTHD2);
        $self->format_part(2,$format);
			}
		}
		$self->mount_parts();
		if ($self->hdmounted==1) {
		  if ($self->goinstpart>0) {
			  my $log = DEFPART.$self->goinstpart."/install.log";
				$self->doit("rm -rf $log") if -e $log;
		  }
		  $self->logadd("now doing the installation");
      $self->gauge(40,WAIT);
			$self->install_os(); # install the os (from squashfs file)
	    $msg = $self->msg(END1)."\n\n".$self->msg(END2);
		  my $cmd = "cat /proc/cpuinfo 2>/dev/null ".
			          "| grep 'model name' 2>/dev/null ".
			          "| grep 'QEMU Virtual'";
		  my $ck = `$cmd 2>/dev/null`;
			if ($ck ne "") {
	      $msg = $self->msg(END1)."\n\n".$self->msg(END4);
			}
			$msg .= "\n\n".$self->msg(END3) if $self->backupinst==0;
	    $self->msgbox($msg);
			if (($self->auto==0 && $self->iso eq "") || $self->stickauto==1) {
			  if ($ck ne "" && $self->stickauto==0) {
	        $self->doit("poweroff"); # reboot for restarting os
				} else {
	        $self->doit("reboot"); # reboot for restarting os
				}
			} elsif ($self->iso ne "") {
			  my $cmd = "umount ".DEFCD;
				$self->doit($cmd);
			}
			system("echo 'done' >/tmp/update.txt");
		} else {
		  $self->writelog("/log");
	    print "error: partitions not mounted\n";
		}
	} else {
	  print "some partitions already mounted\n";
	}
}



# install the os from squashfs file

sub install_os {
  my ($self) = @_;
	$self->goinstpart(1) if $self->goinstpart != 2;
	my $to = DEFPART.$self->goinstpart();
	my $res = "$to/result";
	my $hd = $self->hdcurrent;
  $self->gauge(45,WAIT);
  $self->doit("swapon ".$self->hdcurrent."3");
  $self->gauge(48,INSTOS);
	# we use unsquashfs to install our system
  my $mok="unsquashfs-done";
  my $merr="unsquashfs-not-done";
	my $prg ="unsquash";
	my $cmd = "/etc/perl/$prg";
	$cmd = "/$prg" if -e "/$prg";
	$cmd = "$cmd ".DEFCD."/system.os $to $res $mok $merr &";
	$self->logadd($cmd); # add log message, we process it in background
	system($cmd);
	my $maxtrials=200;
	for (my $c=1;$c<$maxtrials;$c++) {
	  if (-s $res >0) {
	    my $cont = $self->read_file($res);
      if ($cont =~ /$mok/) {
        $self->logadd("installing of squashfs ended");
        $c=$maxtrials;
      } else {
			  $self->install_os_gauge($c,1);
			}
	  } else {
	    $self->install_os_gauge($c,2);
	  }
	}
  $self->gauge(90,FINISH); # move to unpacked data to final destination
	$self->doit("cp -rp $to/boot/grub /");
	$self->doit("mv $to/squashfs-root/* $to");
	$self->doit("rm -Rf $to/squashfs-root");
	$self->doit("mkdir $to/proc");
	$self->doit("mkdir $to/sys");
	$self->doit("rm $to/root/.bash_history");
  $self->gauge(95,WAIT);
	# ad a new fstab fileA
	my $cont = $hd.$self->goinstpart." ".
	           DEFPART_ROOT." ext3 errors=remount-ro,relatime 0 1\n".
	           $hd."4 ".DEFPART_DATA." ext4 defaults,relatime 0 1\n".
						 $hd."3 swap swap sw 0 0\n".
						 "proc /proc defaults 0 0\n";
	$self->doit("echo \"$cont\" >$to/etc/fstab");
  $self->gauge(96,WAIT);
	my $dmsfrom = "$to/var/lib/vz/datadms";
	my $dmsto = DEFPART4."/datadms";
	$cmd = "";
	if ($self->backupinst>0) {
	  # if we do an update, restore the values
	  $self->update_restore($dmsfrom,$dmsto);
	} else {
	  # in a fresh installation add network files
		$self->ip_set($to);
		$cmd = "mkdir ".DEFPART4."/images";
		$self->doit($cmd);
		$cmd = "mkdir ".DEFPART4."/template";
		$self->doit($cmd);
		$cmd = "mkdir ".DEFPART4."/template/iso";
		$self->doit($cmd);
	}
  $self->gauge(97,WAIT);
	if (-e "$dmsfrom" && !-e "$dmsto") {
	  $cmd = "mv $dmsfrom ".DEFPART4;
    $self->doit($cmd);
	}
	$self->install_installer();
	$cmd = "mkdir $to".DEFPART_DATA; # add the needed folder for working
	$self->doit($cmd);
	# adjust grub entry (where to start after installation/update)
	my $newpart = $self->goinstpart;
	$newpart = $newpart-1;
	$cont = "root (hd0,$newpart)\nsetup (hd0)\nquit\n";
	my $c1 = "root (hd1,$newpart)\nsetup (hd1)\nquit\n";
  $self->gauge(98,WAIT);
	$self->writelog("$to/install.log");
	$self->mount_parts(); # remount the partitions so we can install grub
	my $dev = "";
	if ($hd eq "/dev/vda") {
		$dev = "--device-map=/device.map";
		my $cmd = "cp -rp $to/boot/grub/* /";
		$self->doit($cmd);
	  $cmd = "echo \"(hd0)   /dev/vda\">/device.map";
		$self->doit($cmd);
	}
	$self->cmdlinedo($to);
	$self->doit("grub $dev --no-floppy --batch 2>/dev/null <<EOF\n$cont\nEOF\n");
	if ($self->hdcurrent eq "/dev/md") {
	  $self->doit("grub $dev --no-floppy --batch 2>/dev/null <<EOF\n$c1\nEOF\n");
	}
  $self->gauge(99,WAIT);
	if ($self->raiddevice ne "") {
	  $cmd = "mdadm --examine --scan >$to/etc/mdadm/mdadm.conf";
		$self->doit($cmd);
	}
	$self->grub_raiddrive();
	$self->grub_virtiodrive();
  $self->grub_installall($to);
	my $file = DEFCD."/checkit";
	my $filep = "home/cvs/archivista/webclient/perl";
	if (-e $file) {
	  if (-d "$to/$filep") {
	    $cmd = "cp -rp $file $to/$filep";
		  $self->doit($cmd);
		}
	}
	$self->install_postproc($to);
	$self->install_mactab($to);
	$self->writelog("$to/install.log");
}



# install a post processing programm (start after installing/updating it

sub install_postproc {
  my ($self,$to) = @_;
	my $file = "postproc.sh";
	my $file1 = DEFCD."/$file";
	if (-e $file1) {
	  my $cmd = "cp -f $file1 $to";
		$self->doit($cmd);
		$self->doit("chmod a+x $to/$file");
  } else {
	  if (-e "$to/$file") {
		  $self->doit("rm -f $to/$file");
		}
	}
}



# install a mactab table

sub install_mactab {
  my ($self,$to) = @_;
	my $file = "";
	$file .= "eth0 ".$self->eth0."\n" if $self->eth0 ne "";
	$file .= "eth1 ".$self->eth1."\n" if $self->eth1 ne "";
	$file .= "eth2 ".$self->eth2."\n" if $self->eth2 ne "";
	$file .= "eth3 ".$self->eth3."\n" if $self->eth3 ne "";
	$file .= "eth4 ".$self->eth4."\n" if $self->eth4 ne "";
	if ($file ne "" && !-e "$to/etc/mactab") {
	  open(FOUT,">$to/etc/mactab");
		print FOUT $file;
		close(FOUT);
		$file =~ s/(eth)/mth/g;
	  open(FOUT,">$to/etc/mactemp");
		print FOUT $file;
		close(FOUT);
	}
}



# send message out for progress

sub install_os_gauge {
  my ($self,$c,$mode) = @_;
  my $c1 = $c % 40;
	$c1 = $c1 + 50;
	if ($c>40 && $c1<20) {
	  $c1 = $c1 + 20
	}
  $self->gauge($c1,INSTOS);
	sleep 3;
	$self->logadd("part $mode -- wait for end of install process");
}



# unmount part 1, part 2 and part 4

sub unmount {
  my ($self) = @_;
	my $hd = $self->hdcurrent;
	$self->doit("umount ".$hd."1");
	$self->doit("umount ".$hd."2");
	$self->doit("umount ".$hd."4");
	$self->hdmounted(0);
}



# execute a command and lot it

sub doit {
  my ($self,$cmd,$nolog) = @_;
	$self->logadd($cmd);
	my $res = `$cmd 2>/dev/null`;
	$self->logadd($res);
}



# add content to the log file (saved here in memory)
sub logadd {
  my ($self,$cont) = @_;
	my $log = $self->logit;
	$log .= $cont."\n";
	$self->logit($log);
}



# write the log file to the current harddisk partition

sub writelog {
  my ($self,$file) = @_;
	my $cont = $self->logit;
	open(FOUT,">>$file");
	print FOUT $cont;
	close(FOUT);
}



# mount all three  harddisk partitions

sub mount_parts {
  my ($self) = @_;
	$self->doit("umount ".DEFPART1);
	$self->doit("umount ".DEFPART2);
	$self->doit("umount ".DEFPART4);
	$self->doit("mkdir ".DEFHD) if !-d DEFHD;
	$self->doit("mkdir ".DEFPART1) if !-d DEFPART1;
	$self->doit("mkdir ".DEFPART2) if !-d DEFPART2;
	$self->doit("mkdir ".DEFPART4) if !-d DEFPART4;
	$self->doit("touch ".DEFPART4."/mounted");
  my $hd = $self->hdcurrent;
	my $cmd = "mount $hd"."1 ".DEFPART1;
	$self->doit($cmd);
	$cmd = "mount $hd"."2 ".DEFPART2;
	$self->doit($cmd);
	$cmd = "mount -t ext4 $hd"."4 ".DEFPART4;
	$self->doit($cmd);
	if (!-e DEFPART4."/mounted") {
    $self->hdmounted(1);
	} else {
	  $cmd = "mount -t ext4 /dev/drbd0 ".DEFPART4;
		$self->doit($cmd);
		if (! -e DEFPART4."/mounted") {
	    $self->hdmounted(1);
		} else {
	    $self->hdmounted(0);
		}
	} 
}


# check if the current harddisk is alredy mounted

sub check_mounted {
  my ($self) = @_;
	my $result = `df 2>/dev/null`;
	my @devs = split("\n",$result);
	shift @devs;
	my $mounted=0;
	foreach my $def (@devs) {
	  my $pos = index($def,$self->hdcurrent);
		if ($self->iso eq "") {
		  $mounted=1 if $pos==0;
		}
	}
  $self->hdmounted($mounted);
	return $mounted;
}



# give back the root disk

sub check_root {
  my ($self) = @_;
	my $result = `df 2>/dev/null`;
	my @devs = split("\n",$result);
	shift @devs;
	my $roothd = "";
	if ($self->iso ne "" || $self->confsave==1 || $self->confload==1) {
	  foreach my $def (@devs) {
	    my @parts = split(/\s+/,$def);
		  my $part = $parts[0];
		  my $mp = $parts[5];
		  if ($mp eq '/') {
		    $part =~ s/(.*)([0-9]{1,1}$)/$1/;
				my $nr = $2;
		    if ($nr==2) {
	        $self->backupinst(2);
			    $self->goinstpart(1); # installation goes to frist partition
			  } else {
		      $self->backupinst(1);
			    $self->goinstpart(2); # installation goes to second partition
			  }
		    $roothd = $part;
		    last;
			}
		}
	}
	return $roothd;
}




sub format_raid {
  my ($self) = @_;
  if ($self->raiddevice ne "") {
	  my @hds = split(/\s/,$self->raidhds);
		foreach my $hd (@hds) {
      my $cmd = "mdadm --zero-superblock $hd";
			$self->doit($cmd);
		  for (my $c=1;$c<=4;$c++) {
		    my $part = $c;
        $cmd = "mdadm --zero-superblock $hd$part";
				$self->doit($cmd);
			}
		}
	  for (my $c=1;$c<=4;$c++) {
	    my $part = $c;
		  my $hdpart = $self->raiddevice.$part;
			my $cmd = "mdadm --create $hdpart ";
			if ($self->raidlevel eq "raid1" || $part<4) {
			  $cmd .= "--level=1 ";
			} else {
			  if ($self->raidlevel eq "raid0") {
			    $cmd .= "--level=0 ";
				} elsif ($self->raidlevel eq "raid5") {
			    $cmd .= "--level=5 ";
				} elsif ($self->raidlevel eq "raid6") {
			    $cmd .= "--level=6 ";
				} else {
			    $cmd .= "--level=10 ";
				}
			}
			my $disks = "";
			my $raid10 = 0;
			$raid10 = 1 if $self->raidlevel eq "raid10";
			my $c1 = 0;
			foreach my $hd (@hds) {
			  $c1++;
				# if we have raid10, we use:
				# sda1/sda2 + sdb1/sdb2 as raid1 for os
				# sdc3 + sdd3 as raid1 for swap 
				# only sda4, sdb4, sdc4, sdd4 .. we use as raid10 for data partition
			  next if ($part==1 || $part==2) && $raid10==1 && $c1>2;
				next if $part==3 && $raid10==1 && ($c1<=2 || $c1>4);
			  $disks .= " " if $disks ne "";
				my $disk1 .= "$hd$part";
				$disks .= $disk1;
			}
			my $diskcount = $self->raidcount;
			$diskcount=2 if $raid10==1 && $part<4;
			$cmd .= "--assume-clean --chunk=128 ";
			$cmd .= "--raid-disks=$diskcount $disks";
			$cmd = "echo y 2>/dev/null |$cmd";
		  $self->doit($cmd);
		}
  }
}



# calculate the partitions inside of the harddisk

sub format_hd {
  my ($self) = @_;
	my @hds = ();
	if ($self->raiddevice ne "") {
    @hds = split(/\s/,$self->raidhds) 
	} else {
	  push @hds,$self->hdcurrent;
	}
	my $c=15;
	foreach my $hd (@hds) {
    my $bootsize = $self->part_os;
    my $swapsize = $self->part_swap;
    my $linuxstart = $bootsize;
    my $linuxstart2 = $bootsize+$bootsize;
    my $linuxstart3 = $bootsize+$bootsize+$swapsize;
		my $tos = "0x83";
		my $tswap = "0x82";
		if ($self->raiddevice ne "") {
		  $tos = "0xfd";
			$tswap = "0xfd";
		}
	  if ($linuxstart3<$self->hdsize) {
      my $cmd = "echo -e \"".
        "0,$bootsize,$tos,*\n".
        "$linuxstart,$bootsize,$tos,*\n".
        "$linuxstart2,$swapsize,$tswap\n".
        "$linuxstart3,,$tos\"";
      $self->logadd("$cmd");
      my $cmd2 = "$cmd 2>/dev/null |sfdisk -q --no-reread -f -uB ".$hd;
      $self->logadd("$cmd$cmd2");
      $self->doit($cmd2);
			$c++;
      $self->gauge($c,FORMATHD);
		}
	}
  $self->format_raid();
	my $format = "ext3";
  my $swap = "swap";
  $self->gauge(15,PARTHD1);
  $self->format_part(1,$format);
  $self->gauge(20,PARTHD2);
  $self->format_part(2,$format);
  $self->gauge(25,PARTHD3);
  $self->format_part(3,$swap);
  $self->gauge(30,PARTHD4);
  my $size = 131072;
	my $bighd0 = 600*1024*1024; # harddisks over 600 gb
	my $bighd1 = 900*1024*1024; # harddisks over 900 gb
	my $bighd2 = 1200*1024*1024; # harddisks over 1200 gb
	$size = $size * 2 if $self->hdsize>$bighd0;
	$size = $size * 2 if $self->hdsize>$bighd1;
	$size = $size * 2 if $self->hdsize>$bighd2;
	$format = "ext4";
  $self->format_part(4,$format,$size);
}



# format a single partion (at this moment with ext3)

sub format_part {
  my ($self,$part,$format,$size) = @_;
	my $hd = $self->hdcurrent();
  my $cmd = "";
	my $opt = "";
	$opt = "-i $size" if $size>0;
	my $hdpart = "$hd$part";
  if ($format eq "ext3") {
    $cmd = "mkfs.ext3 $opt $hdpart";
  } elsif ($format eq "ext4") {
    $cmd = "mkfs.ext4 $opt $hdpart";
  } elsif ($format eq "swap") {
    $cmd = "mkswap $hdpart";
  }
  if ($cmd ne "") {
    $self->doit($cmd);
  }
}



# install grub to all hds

sub grub_installall {
  my ($self,$to) = @_;
	if ($self->hdcurrent eq "/dev/md") {
	  # we are in software raid, so adjust grubs
	  my $mdtemp = "/tmp/mdtemp";
		mkdir $mdtemp if !-e $mdtemp;
		my $cmd1 = "echo 'mdtemp' >$mdtemp/mdtest";
		$self->doit($cmd1);
		my @short = ();
		my @exclude = ();
    my $hdnummer = 0;
		$self->grub_installdrives("md4",\@short);
		$self->grub_installdrives("md8",\@short);
		$self->grub_installdrives("md1",\@exclude);
		@short = sort @short;
		@exclude = sort @exclude;
		foreach my $disk (@short) {
		  #last if $disk eq "sdi"; # only prepare first 8 disks (grub problem)
		  if ($disk ne $exclude[0] && $disk ne $exclude[1]) {
	      my $partnr = $self->goinstpart;
			  my $device = "/dev/$disk$partnr";
			  my $cmd = "mount $device $mdtemp";
				$self->doit($cmd);
				if (-e "$mdtemp/mdtest") {
				  # drive is not ok, so create md and format it
					$cmd = "mkfs.ext3 $device";
					$self->doit($cmd);
			    $cmd = "mount $device $mdtemp";
					$self->doit($cmd);
				}
				if (!-e "$mdtemp/mdtest") {
				  # drive is mounted, so add grub information
					$cmd = "cp -rp $to/boot $mdtemp";
					$self->doit($cmd);
			    $partnr = $partnr-1;
	        my $cont = "root (hd$hdnummer,$partnr)\nsetup (hd$hdnummer)\nquit\n";
          $self->gauge(98,WAIT);
					my $opt = "--no-floppy --batch";
        	$self->doit("grub $opt 2>/dev/null <<EOF\n$cont\nEOF\n");
          $self->gauge(99,WAIT);
				}
				$cmd = "umount $device";
				$self->doit($cmd);
			}
			$hdnummer++;
		}
	}
}



# add drvies for grub reinstallation

sub grub_installdrives {
  my ($self,$mdnr,$pshort) = @_;
	my $res = `cat /proc/mdstat 2>/dev/null | grep '$mdnr' 2>/dev/null`;
	if ($res ne "") {
    my @disks = split(" ",$res);
    shift @disks;
    shift @disks;
    shift @disks;
    shift @disks;
		foreach my $disk (@disks) {
		  my ($disk1,$disk2) = split(/\[/,$disk);
			$disk1 =~ s/([0-9]$)//;
			push @$pshort,$disk1;
		}
	}
}



# install everything in ram

sub install_ram {
  my ($self) = @_;
  $self->gauge(10,WAIT);
  $self->doit("unsquashfs -dest /os /tmp/cd/system.os");
  $self->gauge(40,WAIT);
  $self->doit("mv -f /os/* /");
  $self->gauge(42,WAIT);
  $self->doit("cp -rp /os/* /");
  $self->gauge(44,WAIT);
  $self->doit("rm -Rf /os");
  $self->gauge(46,WAIT);
  $self->doit("cp /mess* /etc/perl");
  $self->doit("cp /unsquashfs /etc/perl");
  $self->doit("cp /install.pl /etc/perl");
	$self->install_postproc("");
	$self->install_mactab("");
  $self->choose_networking();
  $self->gauge(50,WAIT);
  $self->ip_set(""); 
  $self->gauge(60,WAIT);
  my $init = "/etc/init.d";
  $self->doit("$init/networking restart");
  $self->doit("$init/hostname.sh start");
  $self->doit("ifconfig lo 127.0.0.1");
  $self->gauge(65,WAIT);
  $self->doit("tar cvfz /vz.tgz /var/lib/vz");
  my $devswap = $self->hdcurrent."3";
  my $devdata = $self->hdcurrent."4";
	if ($self->ramdata eq "" && $self->ramdisk==0) {
    $self->init_raid();
    $self->doit("mdadm --examine --scan >/etc/mdadm/mdadm.conf");
    my $cmd = "sfdisk -d ".$self->hdcurrent." 2>/dev/null";
    $self->logadd($cmd);
    my $res = `$cmd`;
    if ($res eq "") {
      $cmd = "cat /etc/mdadm/mdadm.conf 2>/dev/null";
      $self->logadd($cmd);
      $res = `$cmd`;
      if ($res eq "" && $self->formathd==1) {
        $self->format_hd();
      }
    }
    $self->gauge(80,WAIT);
	}
	if ($self->ramdisk eq "") {
	  $devdata = $self->ramdata if $self->ramdata ne "";
	  $devswap = $self->ramswap if $self->ramswap ne "";
	} else {
	  my $disk = $self->cdcurrent;
		$disk =~ s/([0-9]*)$//;
		$devdata = $disk."3";
		$devswap = $disk."2";
  }
  $self->doit("swapon $devswap");
  $self->doit("mount $devdata /var/lib/vz");
  if (!-e "/var/lib/vz/images") {
    $self->doit("tar xvfz vz.tgz");
  }
  $self->gauge(86,WAIT);
  $self->doit("$init/ssh start");
  $self->doit("$init/xcfgt2init start");
  $self->doit("$init/qemu-server start");
  $self->gauge(88,WAIT);
  $self->doit("$init/pvedaemon start");
  $self->gauge(90,WAIT);
  $self->doit("$init/pvenetcommit start");
  $self->gauge(92,WAIT);
  $self->doit("$init/pvemirror start");
  $self->gauge(94,WAIT);
  $self->doit("$init/pvetunnel start");
  $self->gauge(96,WAIT);
  $self->doit("$init/apache2 start");
  $self->gauge(98,WAIT);
	$self->cmdlinedo("/");
	if (-e "/etc/init.d/mysql") {
    $self->doit("$init/mysql start");
	}
	if (-e "/etc/init.d/avboxcheck") {
    $self->doit("$init/avboxcheck start");
	}
	my $script1 = "/home/cvs/archivista/jobs/notify-daemon.pl";
	my $script2 = "/home/cvs/archivista/jobs/sane-daemon.pl";
	my $script3 = "/home/cvs/archivista/jobs/createpdf.pl";
	system("nohup $script1 &") if -e $script1;
	system("nohup $script2 &") if -e $script2;
	system("nohup $script3 &") if -e $script3;
  $self->doit("cp /go /usr/bin");
	my $msg = $self->msg(END1)." ".$self->msg(RAMSTART)."\n\n";
	$msg .= $self->msg(RAMSTART1).$self->ip()."\n";
	$msg .= $self->msg(RAMSTART2);
  $self->msgok($msg,1);
}


1;


