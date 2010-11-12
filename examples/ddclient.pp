package {"ddclient":
   ensure => installed,
}	
file { "/etc/ddclient.conf":
  owner   => 'root',
  mode    => '600',
  content => "# Manager by puppet
pid=/var/run/ddclient.pid
protocol=dyndns2
use=if, if=eth1
server=members.dyndns.org
login=niklausgiger
password=niklaus_g2
cosre.dyndns.org
wildcard=yes
"
}

file { "/etc/default/ddclient":
  owner   => 'root',
  mode    => '600',
  content => "# Manager by puppet
syslog='true'
run_ipup='true'
run_daemon='true'
daemon_interval='300'
"
}
exec {"/usr/local/bin/ainsl /etc/resolv.conf '# Manager (partly) by puppet'": }
exec {"/usr/local/bin/ainsl /etc/resolv.conf 'domain cosre.dyndns.org'": }
exec {"/usr/local/bin/ainsl /etc/resolv.conf 'search cosre.dyndns.org'": }

