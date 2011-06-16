# Configuration parts

ELEXIS_ADMIN_Common_Preseed=<<EOF
apt-mirror-setup	apt-setup/use_mirror    boolean true
apt-mirror-setup	apt-setup/no_mirror	boolean	false
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

d-i partman/mount_style select uuid
#d-i console-tools/archs select at
d-i     console-data/keymap/template/layout     select  Swiss
d-i     console-data/keymap/family      select  qwertz

EOF

ELEXIS_ADMIN_PACKAGES=<<EOF
openssh-client
openssh-server
openvpn
anacron
rsync
sudo
vim
git-core
etckeeper
htop
parted
dlocate
locate
findutils
kbd
unzip

lsb-release
# damit debconf-get-selections zur Verfuegung steht
debconf-utils

# to allow loadkeys sg
console-data
# to have a mouse in the kvm console window
gpm
pciutils
usbutils

puppet
# Added to fix error when demanding puppet
libruby

EOF
