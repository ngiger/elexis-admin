#!/usr/bin/ruby
InitialPassword="elexisTest"                                 
InitialUser="elexis"                                   
AdminEmail="niklaus.giger@swissonline.ch"              
AdminPuppet="git://github.com/ngiger/elexis-admin.git" 
PuppetClient="git@github.com:ngiger/giger.git"

ARCH='i386' if !defined?(ARCH)

load "common/elexis_admin.rb"
load "common/hd_layout_vm.rb"

cnf_vm = SimpleCddConf.new(File.basename(__FILE__, '.rb'))
cnf_vm.release='squeeze'
cnf_vm.locale='de_CH'
cnf_vm.description = "Debian #{cnf_vm.release} Server (no X, #{cnf_vm.locale}, puppet, openvpn)"

cnf_vm.conf=<<EOF
mirror_components="main contrib non-free"

EOF
if defined?(ARCH) and ARCH=='i386'
  ELEXIS_ADMIN_PACKAGES+="\nlinux-image-2.6-686-bigmem\n"
end

cnf_vm.packages=<<EOF
#{ELEXIS_ADMIN_PACKAGES}
EOF

cnf_vm.packages+="git\n"
cnf_vm.preseed=<<EOF
#{ELEXIS_ADMIN_Common_Preseed}
#{Layout_HD_VM_Server}
EOF

puts cnf_vm.postinst.inspect
cnf_vm.postinst = '' if !cnf_vm.postinst
cnf_vm.postinst+=<<EOF
#!/bin/sh
logger "ELEXIS_ADMIN: running $0"

# some additional setup for etckeeper
cd /etc
git config --system user.name  #{AdminEmail}
git config --system user.email #{AdminEmail}

etckeeper init
echo "*~" >.gitignore
git add .gitignore
git commit -m "Initial commit from simple-cdd postinst"

# echo RAMRUN=yes >>  /etc/default/rcS
# echo RAMLOCK=yes >>  /etc/default/rcS

echo "# Kernel image management overrides" >  /etc/kernel-img.conf
echo "# See kernel-img.conf(5) for details" >>  /etc/kernel-img.conf
echo "do_symlinks = yes" >>  /etc/kernel-img.conf
echo "relative_links = yes" >>  /etc/kernel-img.conf
echo "do_bootloader = no" >>  /etc/kernel-img.conf
echo "do_bootfloppy = no" >>  /etc/kernel-img.conf
echo "do_initrd = yes" >>  /etc/kernel-img.conf
echo "link_in_boot = no" >>  /etc/kernel-img.conf

cmd="git clone #{PuppetClient} /etc/puppet"
logger "ELEXIS_ADMIN: running $cmd"
$cmd

# Add key for our git host
echo "|1|ptiz5VZG3I7H1BgruPLSBO+L6fg=|HrysmQGjotRohSOp59+zo0rV1jU= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" > /home/${InitialUser}/.ssh/known_hosts
echo "alias ll='ls -al'" >> /home/${InitialUser}/.bash_aliases
echo "alias ll='ls -al'" >> /etc/skel/.bash_aliases
update-alternatives --set editor /usr/bin/vim.basic
echo '#{InitialUser} ALL=(ALL) ALL' >> /etc/sudoers.d/#{InitialUser}

EOF
cnf_vm
