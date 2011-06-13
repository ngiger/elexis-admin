class x2go::common {
  $x2go_dpkg_list =  "/etc/apt/sources.list.d/10_x2go.list"
  file {$x2go_dpkg_list: ensure => present,
    owner   => root,
    content => "deb http://x2go.obviously-nice.de/deb/ lenny main\n",
  }

  exec { "init_x2go_key":
 command => "gpg --quiet --keyserver pgp.mit.edu --recv-keys su ; gpg -a --export C509840B96F89133 | sudo apt-key add -",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    unless  => "apt-key list | grep obviously-nice.de",
    refreshonly => true,
    before => File[$x2go_dpkg_list],
  }	

  exec {'x2go_apt_update':
    command => "apt-get update",
    path    => "/usr/bin:/usr/sbin:/bin:/sbin",
    refreshonly => true,
    require => File[$x2go_dpkg_list],
  }	

  package { "openssl":
    ensure => installed,
  }	
  package { "gnupg":
    ensure => installed,
  }	
}