exec { "wget http://www.informatik.uni-koeln.de/ls_juenger/people/lange/software/ainsl --directory-prefix=/usr/local/bin/":
  alias   => 'ainsl',
  creates => "/usr/local/bin/ainsl",
  path    => "/usr/bin:/usr/sbin:/bin:/sbin",
}

file { "/usr/local/bin/ainsl":
  owner   => root,
  mode    => 0755,
  require => Exec[ainsl],
} 

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

exec {"/usr/local/bin/ainsl /etc/ssh/sshd_config 'Port 8245'": }

file { "/mnt/template":
  ensure => directory,
  owner   => root,
  mode    => 0755,
}
file { "/mnt/share":
  ensure => directory,
  owner   => root,
  mode    => 0755,
}

mount{ "/mnt/template":
  ensure   => mounted,
  options  => "username=administrator,password=monagrillo",
  fstype   => "cifs",
  device   => "//192.168.26.243/template",
  require  => File["/mnt/template"],
  remounts => true,
  pass     => "2"
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
 

package { "samba":
   ensure => installed,
}	


file { "/etc/samba/smb.conf": ensure => present,
  owner   => root,
  mode    => 0644,
  content => '
[global]
   workgroup = DOCS
   server string = %h server
   include = /etc/samba/dhcp.conf
   dns proxy = no
   log file = /var/log/samba/log.%m
   max log size = 1000
   panic action = /usr/share/samba/panic-action %d
   encrypt passwords = true
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes

[printers]
   comment = All Printers
   browseable = no
   path = /var/spool/samba
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700

[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no

[homes]
  comment = Classeur de l\'utilisateur
  browseable = yes
  read only = no
  create mask = 0700
  directory mask = 0700
  valid users = %S

[data]
    comment = Données du Cabinet du Dr. Büchel
    read only = no
    locking = yes
    path = /opt/data
    guest ok = no
'
}

