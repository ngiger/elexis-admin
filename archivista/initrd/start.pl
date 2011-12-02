#!/usr/bin/perl

use strict;
my $opt = shift;
my $init = "/etc/init.d";
doit("$init/networking restart");
doit("ifconfig lo 127.0.0.1");
if ($opt==1) {
  doit("swapon /dev/sda3");
  doit("mount /dev/sda4 /var/lib/vz");
}
doit("$init/ssh start");
doit("$init/xcfgt2init start");
doit("$init/qemu-server start");
doit("$init/pvedaemon start");
doit("$init/pvenetcommit start");
doit("$init/pvemirror start");
doit("$init/pvetunnel start");
doit("$init/apache2 start");
print "Start it with web browser OR with 'su - archivista'; and 'startx'\n";

sub doit {
  my ($cmd,$ask) = @_;
  print "$cmd\n";
  if ($ask != 0) {
    print "Press enter...\n";
    <>;
  }
  system($cmd);
}
