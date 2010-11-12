#!/usr/bin/ruby

require 'demo_dhcp'
cnf_fix = SimpleCddConf::get('demo_dhcp').copyTo(File.basename(__FILE__, '.rb'))

cnf_fix.preseed+=<<EOF
d-i netcfg/disable_dhcp boolean true
d-i netcfg/dhcp_failed note
d-i netcfg/dhcp_options select Configure network manually

# Static network configuration.
d-i netcfg/get_nameservers string 172.25.1.1
d-i netcfg/get_ipaddress   string 172.25.1.242
d-i netcfg/get_netmask     string 255.255.255.0
d-i netcfg/get_gateway     string 172.25.1.1
d-i netcfg/confirm_static  boolean true
EOF
