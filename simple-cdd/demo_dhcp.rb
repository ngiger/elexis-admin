#!/usr/bin/ruby


cnf = SimpleCddConf.new(File.basename(__FILE__, '.rb'))

# In this a few things which you probably would like to adapt for your problem
InitialPassword="1024" # For InitialUser and root
InitialUser="elexis"
AdminEmail="niklaus.giger@swissonline.ch"
AdminPuppet="git://github.com/ngiger/elexis-admin.git"

cnf.description='Demo-Server using DHCP'
cnf.release='lenny'
cnf.locale='fr_ch'
cnf.conf=<<EOF
mirror_components="main contrib non-free"
security-mirror="http://security.debian.org/"
EOF


if defined?(ARCH) and ARCH=='x86'
  cnf.conf+="kernel-packages=\"linux-image-2.6-686-bigmem\"\n"
end

cnf.packages=<<EOF
puppet
puppetmaster
openssh-client
openssh-server
anacron
rsync
sudo
vim
etckeeper
smartmontools
parted
dlocate
locate
findutils
kbd
pciutils
usbutils
EOF
if cnf.release=='lenny'
cnf.packages+="git-core\n"
else
cnf.packages+="git\n"
end

cnf.postinst=<<EOF
#!/bin/sh
logger "COSRE: running $0"

# Under lenny we need some additional setup for etckeeper
cd /etc
etckeeper init
echo "*~" >.gitignore
git add .gitignore
git commit -m "Initial commit from simple-cdd postinst"

update-alternatives --set editor /usr/bin/vim.basic
echo '#{InitialUser} ALL=(ALL) ALL' >> /etc/sudoers
# SMART configuration
echo 'start_smartd=yes'>>/etc/default/smartmontools
echo 'DEVICESCAN -a -o on -S on -s (S/../.././02|L/../../6/03) -m #{AdminEmail}' >/etc/smartd.conf
# we want to checkout into /etc/elexis-admin to clearly show that we want to run standalone
cd /etc 
rm -rf puppet
git clone #{AdminPuppet}
# comment out the next lie if you don't want to a daily update 
echo '/usr/bin/puppet /etc/#{File.basename(AdminPuppet,'.git')}/manifest/site.pp' >/etc/cron.daily/run_puppet

git commit -m 'commit after cloning puppet' -a
EOF

cnf.preseed=<<EOF
d-i netcfg/get_hostname string  elexis-admin
d-i netcfg/get_domain   string  elexis.arztpraxis.demo
apt-mirror-setup	apt-setup/use_mirror    boolean false
apt-mirror-setup	apt-setup/no_mirror	boolean	true
choose-mirror-bin	mirror/http/hostname	string	ftp.ch.debian.org

user-setup-udeb	passwd/username	string	#{InitialUser.upcase}
user-setup-udeb	passwd/user-fullname	string	#{InitialUser}
d-i   popularity-contest/participate  boolean false

passwd passwd/root-password password #{InitialPassword}
passwd passwd/root-password-again password #{InitialPassword}
d-i passwd/user-fullname string #{InitialUser}
d-i passwd/username string #{InitialUser}
passwd passwd/user-password password #{InitialPassword}
passwd passwd/user-password-again password #{InitialPassword}
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
