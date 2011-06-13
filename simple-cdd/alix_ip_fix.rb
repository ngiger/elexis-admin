#!/usr/bin/ruby

# Test/burn it into the CF-Flash (/dev/sdb) using
# kvm -hda /dev/sdb -cdrom images/debian-testing-i386-CD-1.iso -boot 
# TODO: xserver für kvm & alix
# TODO: x2gothinclient so installieren dass er startet
#       in /etc/X11/xinit/xinitrc ". ./xession" durch "x2goclient" ersetzen!
#       Evtl. PXE/LDAP einführen
# TODO: smartmontools nicht installieren
# TODO: Richtige mirror für CH und x2go
# Kernel-Config see http://www.pcengines.info/forums/?page=post&id=4C8A8351-5BF2-424A-8EF6-6AFC08D4E0CF&fid=40251191-FF24-48A8-BB0E-995B04812ADE
# oder WRT config für buildroot https://secure.pfountz.com/wiki/Wiki.jsp?page=BensOpenWRTTrunk
require 'demo_dhcp'

cnf_alix_fix = SimpleCddConf::get('demo_dhcp').copyTo(File.basename(__FILE__, '.rb'))
# cnf_alix_fix = SimpleCddConf.new(File.basename(__FILE__, '.rb'))

cnf_alix_fix.release='squeeze'
cnf_alix_fix.locale='de_CH'
cnf_alix_fix.keyboard='sg'y§
cnf_alix_fix.description = "ALIX-Board (#{cnf_alix_fix.locale}, #{cnf_alix_fix.release}) vom  #{Time.now}"
cnf_alix_fix.conf=<<EOF
mirror_components="main contrib non-free"
# security-mirror="http://security.debian.org/"
kernel-packages="linux-image-2.6-486"
EOF

cnf_alix_fix.packages=<<EOF
# puppet
#{COSRE_PACKAGES}
# Fuer Alix
xserver-xorg-video-geode
# Fuer kvm
xserver-xorg-video-cirrus
EOF
cnf_alix_fix.packages.gsub!('smartmontools','')
cnf_alix_fix.preseed=<<EOF
#{COSRE_Common_Preseed}
#{COSRE_FIX_IP}
#{Layout_Alix_Board}
EOF

cnf_alix_fix.postinst+=<<EOF
echo RAMRUN=yes >>  /etc/default/rcS
echo RAMLOCK=yes >>  /etc/default/rcS

echo "# Kernel image management overrides" >  /etc/kernel-img.conf
echo "# See kernel-img.conf(5) for details" >>  /etc/kernel-img.conf
echo "do_symlinks = yes" >>  /etc/kernel-img.conf
echo "relative_links = yes" >>  /etc/kernel-img.conf
echo "do_bootloader = no" >>  /etc/kernel-img.conf
echo "do_bootfloppy = no" >>  /etc/kernel-img.conf
echo "do_initrd = yes" >>  /etc/kernel-img.conf
echo "link_in_boot = no" >>  /etc/kernel-img.conf

echo proc         /proc           proc    defaults                        0       0 >/etc/fstab
echo /dev/sda1    /               ext2    noatime,errors=remount-ro       0       1 >/etc/fstab
echo tmpfs        /tmp            tmpfs   defaults,noatime                0       0 >/etc/fstab
echo tmpfs        /var/tmp        tmpfs   defaults,noatime                0       0 >/etc/fstab

echo allow-hotplug eth0    >  /etc/network/interfaces
echo allow-hotplug eth1   >>  /etc/network/interfaces
echo iface eth0 inet dhcp >>  /etc/network/interfaces
echo iface eth1 inet dhcp >>  /etc/network/interfaces

# Clone read only git
git clone git://github.com/ngiger/elexis-admin.git
EOF
cnf_alix_fix