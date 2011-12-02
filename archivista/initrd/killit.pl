#!/bin/perl

use strict;

my $auto = shift; # pass 1 and after initial question, remove it without y/n
print "$0 (c) by Archivista GmbH, 2011, v0.1\n";
print "Programm does kill raid disks. Please\n";
print "ONLY USE IT IF YOU REALLY KNOW WAHT YOU ARE DOING!!!!!!!!!!!!!!!\n\n";
print "How many drives do you use? (1-x)?";
my $disks = <>;
chomp $disks;
if ($disks>1) {
  load_mdadm();
  my @res = `mdadm --examine --scan`;
  my @mds = ();
  foreach (@res) {
    my ($null,$md,$rest) = split(" ",$_);
	  push @mds, $md;
  }
	foreach my $md (@mds) {
	  if ($md eq "/dev/md3") {
		  doit("swapoff $md");
		} else {
		  doit("umount $md");
		}
	  my $cmd = "mdadm --stop $md";
		doit($cmd,$auto);
	  $cmd = "mdadm --remove $md";
		doit($cmd,$auto);
	}
	my $diskname = "a";
	for (my $c=1;$c<=$disks;$c++) {
	  my $disk = "/dev/sd$diskname";
	  my $cmd = "mdadm --zero-superblock $disk";
		doit($cmd,$auto);
		for (my $c1=1;$c1<=4;$c1++) {
	    my $cmd = "mdadm --zero-superblock $disk$c1";
			doit($cmd,$auto);
			$cmd = "dd if=/dev/zero of=$disk$c1 bs=16M count=1";
			doit($cmd,$auto);
		}
		$diskname++;
	}
}




sub doit {
  my ($cmd,$auto) = @_;
	if ($auto==1) {
    print "$cmd\n";
		system($cmd);
	} else {
	  print "$cmd -- Start it (y/n)?";
	  my $res = <>;
	  chomp $res;
	  if ($res eq "y" or $res eq "Y") {
	    system($cmd);
	  } else {
		  die;
		}
	}
}



sub load_mdadm {
  my $cmd = "modprobe md";
  doit($cmd,1);
  $cmd = "modprobe linear";
  doit($cmd,1);
  $cmd = "modprobe multipath";
  doit($cmd,1);
  $cmd = "modprobe raid0";
  doit($cmd,1);
  $cmd = "modprobe raid1";
  doit($cmd,1);
  $cmd = "modprobe raid456";
  doit($cmd,1);
  $cmd = "modprobe raid6_pq";
  doit($cmd,1);
  $cmd = "modprobe raid10";
  doit($cmd,1);
}
