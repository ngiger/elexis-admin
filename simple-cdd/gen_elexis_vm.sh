#!/bin/bash

# TODO: get this vom debconf when we have our elexis-admin debian package
# sudo debconf-get-selections --installer | grep ng-hp
# netcfg  netcfg/get_hostname     string  ng-hp
# echo "elexis-admin elexis-admin/praxis string giger" | sudo debconf-set-selections

# name: backup
# ide2: archivista_cd1.iso,media=cdrom
# smp: 1
# vlan0: rtl8139=6E:85:C3:EA:F0:29
# bootdisk: ide0
# ide0: vm-102-disk.qcow2
# ostype: l26
# memory: 512

OriginURL="https://raw.github.com/ngiger/elexis-admin/images"
j=101
confDir='.'
newConf=${j}.conf
fName='xxx'
while [ -f /etc/qemu-server/${j}.conf ]
do
  confDir="/etc/qemu-server/"
  # echo "Fand /etc/qemu-server/${j}.conf"
  j=$((${j}+1))
done

isoName="elexis_archivista_latest.iso"
Tgt="/var/lib/vz/template/iso/"
if [ -d ${Tgt} ]
then
  echo "${Tgt} exists"
  cd  ${Tgt}
else
  Tgt='.'
fi
cmd=''
fName="ss"

set_mac_id()
{
  vmId=$1
  mac_id="00:60:13:87:52:`echo \"obase=16;${vmId}\" | bc`"
}

create_qemu_conf()
{
  vmId=$1
  confId=$2
  fName=$3
  cmd="grep ${mac_id} ${confDir}/*.conf"
  if [ ! -f ${confDir}/*.conf ]
  then
      echo "No conf file found, will create ${fName}"
  elif ( $cmd )
  then 
      # echo "MAC ${mac_id} already specified!"
      return 1
  fi
  echo "name: Elexis-VM-${vmId}" >  ${fName}
  echo "ide2: ${isoName},media=cdrom" >>  ${fName}
  echo "smp: 1" >>  ${fName}
  echo "vlan0: rtl8139=${mac_id}" >>  ${fName}
  echo "bootdisk: ide0" >>  ${fName}
  echo "ide0: vm-102-disk.qcow2" >>  ${fName}
  echo "ostype: l26" >>  ${fName}
  echo "memory: 1024" >>  ${fName}
  echo "cache: writeback" >>  ${fName}
  echo "format: qcow2" >>  ${fName}
  echo "onboot: 1" >>  ${fName}
  cmd="/usr/sbin/qm create ${confId} --cdrom debian-unstable-i386-CD-1.iso --name elexis-vm-${vmId} --vlan0 rtl8139=${mac_id} --bootdisk ide0 --ostype l26  --format qcow2 --cache writeback"
#  echo "will cat "  ${fName}
#  cat  ${fName}
  return 0
}


# wget --continue ${OriginURL}/${isoName} 
# j=$((${j}+1))

set_mac_id $j
fName=${confDir}/${j}.conf

vmId=1
# --smp 1  --ide0 32 --memory 512 --onboot yes --description "xy" --smp 2
if ( create_qemu_conf ${vmId} $j $fName )
then
  echo "smp: 1" >>  ${fName}
  echo "memory: 512" >>  ${fName}
  echo "description: elexis-admin VM ${vmId} (main server, db, wiki) with puppet. MAC-id is ${mac_id}"  >> ${fName}
  cmd="/usr/sbin/qm create $j -cdrom debian-unstable-i386-CD-1.iso --name elexis-vm-${vmId}"
  cmd+=" --vlan0 rtl8139=${mac_id} -smp 1 --bootdisk ide0 --ide0 32 --ostype l26 --memory 512 --onboot yes --format qcow2 --cache writeback"
  echo $cmd
  $cmd
# Noch folgendes Kommando ausführen 
# /usr/sbin/qm create 119 --cdrom debian-unstable-i386-CD-1.iso --name elexis-vm-3 --vlan0 rtl8139=32:51:63:FC:FB:0D --smp 1 --bootdisk ide0 --ide0 32 --ostype l26 --memory 512 --onboot yes --format qcow2 --cache writeback
# Formatting '/var/lib/vz/images/119/vm-119-disk.qcow2', fmt=qcow2, size=33554432 kB
# VM 119 created
else
  echo "Skipping ${fName}"
fi

exit

j=$((${j}+1))
create_qemu_conf 2 $j
echo "smp: 2" >>  ${fName}
echo "memory: 2048" >>  ${fName}
echo "description: elexis-admin VM ${vmId} (X2go-Server) with puppet. MAC-id is ${mac_id}"  >>  ${fName}


