file { "/etc/apt/apt.conf": ensure => present,
  owner => root,
  content => 'acquire::http::Proxy "http://fest:3142";
Acquire::http::Proxy::bugs.debian.org "DIRECT";
APT::Cache-Limit 36777216;
'
}

