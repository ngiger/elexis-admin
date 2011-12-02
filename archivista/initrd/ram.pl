#!/usr/bin/perl

use strict;
my $opt = shift;
doit("unsquashfs -dest /os /tmp/cd/system.os");
doit("cp -rp /os/* /");
doit("rm -Rf /os");
doit("cp /mess* /etc/perl");
doit("cp /unsquashfs /etc/perl");
doit("cp /install.pl /etc/perl");
doit("perl install.pl network");
doit("perl /start.pl $opt") if $opt==1;

sub doit {
  my ($cmd,$ask) = @_;
  print "$cmd\n";
  if ($ask != 0) {
    print "Press enter...\n";
    <>;
  }
  system($cmd);
}
