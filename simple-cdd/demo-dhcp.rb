#!/usr/bin/ruby

cnf = SimpleCddConf.new(File.basename(__FILE__, '.rb'))
cnf.description='Demo-Server using DHCP'
cnf.release='lenny'
cnf.keyboard='sf'
cnf.locale='fr_ch'
cnf.conf=<<EOF
# cannot specify non-free!
mirror_components="main contrib",
security-mirror="http://security.debian.org/",
exportall_extras="custom-file,profiles/custom-file",
EOF

if defined?(ARCH) and ARCH=='x86'
  cnf.conf+="kernel-packages=\"linux-image-2.6-686-bigmem\"\n"
end

cnf.packages=<<EOF
# puppet
# puppetmaster
# openssh-client
# openssh-server
# anacron
# rsync
# sudo
# vim
# git
# etckeeper
# smartmontools
# parted
# dlocate
# locate
# findutils
EOF

cnf.postinst=<<EOF
#!/bin/sh
logger "COSRE: running $0"

# Under lenny we need some additional setup for etckeeper
cd /etc
etckeeper init
echo "*~" >.gitignore
git add .gitignore
git commit -m "Initial commit while still in installation"

update-alternatives --set editor /usr/bin/vim.basic
echo 'elexis ALL=(ALL) ALL' >> /etc/sudoers
# SMART configuration
echo 'start_smartd=yes'>>/etc/default/smartmontools
echo 'DEVICESCAN -a -o on -S on -s (S/../.././02|L/../../6/03) -m niklaus.giger@swissonline.ch' >/etc/smartd.conf

EOF

cnf.preseed=<<EOF
apt-mirror-setup	apt-setup/use_mirror    boolean false
apt-mirror-setup	apt-setup/no_mirror	boolean	true
# choose-mirror-bin	mirror/http/hostname	string	ftp.ch.debian.org

user-setup-udeb	passwd/username	string	Elexis
user-setup-udeb	passwd/user-fullname	string	elexis
d-i   popularity-contest/participate  boolean false

passwd passwd/root-password password 1024
passwd passwd/root-password-again password 1024
d-i passwd/user-fullname string elexis
d-i passwd/username string elexis
passwd passwd/user-password password 1024
passwd passwd/user-password-again password 1024
user-setup-udeb passwd/user-default-groups string audio cdrom floppy video plugdev netdev powerdev

d-i partman-auto/expert_recipe string \
condpart :: \
512 512 512 ext3 \
$primary{ } $bootable{ } \
method{ format } format{ } \
label { demarrage } \
use_filesystem{ } filesystem{ ext2 } \
mountpoint{ /boot } \
. \
2048 10240 10240 ext3 \
method{ format } format{ } \
label { premier_systeme } \
use_filesystem{ } filesystem{ ext3 } \
mountpoint{ / } \
. \
2048 10240 10240 ext3 \
method{ format } format{ } \
use_filesystem{ } filesystem{ ext3 } \
label { deuxieme_systeme } \
mountpoint{ /system2 } \
. \
1024 10240 300% linux-swap \
method{ swap } format{ } \
. \
512 5120 5120 ext3 \
method{ format } format{ } \
label { home } \
use_filesystem{ } filesystem{ ext3 } \
mountpoint{ /home } \
. \
512 4096 10000000 ext3 \
method{ format } format{ } \
label { opt } \
use_filesystem{ } filesystem{ ext3 } \
mountpoint{ /opt } \
.

EOF

