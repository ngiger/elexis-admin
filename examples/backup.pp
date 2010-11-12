package { "rdiff-backup":
   ensure => installed,
}	

file { "/etc/cron.daily/backup_$hostname": ensure => present,
  owner   => root,
  mode    => 0700,
  content => "#!/bin/bash
umount /mnt/backup 2>/dev/null
dest=/mnt/share/backup.$hostname 
smbmount //192.168.27.100/share /mnt/share/ -o guest 2>/dev/null
if [ -d \$dest ]
then
logger 'backup: buffalo found'
/usr/bin/rdiff-backup  --exclude-special-files --exclude /usr/local/games --exclude /tmp/\'*\' --exclude /var/tmp/\'*\' --exclude /mnt --exclude /proc --exclude /sys / \$dest 2>&1 >/dev/null
logger 'backup: \$0 done'
else
logger 'backup: \$0 failed, as buffalo could not be mounted'
exit 2
fi
"
}

file { "/mnt/share":
  ensure => directory,
  owner   => root,
  mode    => 0755,
}

mount{ "/mnt/share":
  ensure   => present,
  options  => "username=administrator,password=monagrillo",
  fstype   => "cifs",
  device   => "//192.168.27.100/share",
  require  => File["/mnt/share"],
  remounts => true,
  pass     => "2"
}
 
