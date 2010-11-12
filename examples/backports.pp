# We should use real resources to get the dependencies right!
file { "/etc/apt/sources.list.d/01_backports.list": ensure => present,
  alias => "apt_pref",
  owner => root,
  content => "deb http://backports.debian.org/debian-backports lenny-backports main contrib non-free\n"
 }
# aptitude -t lenny-backports install name


# defined in the test class
 exec { "aptitude --assume-yes update":
  alias => "apt_update",
  # require => 'apt_pref',
     path => "/usr/bin:/usr/sbin:/bin:/sbin",
     onlyif => "dpkg -l puppet | grep 0.2"
}

 exec { "aptitude --assume-yes --quiet -t lenny-backports install puppet":
 # require => 'apt_update',
     path => "/usr/bin:/usr/sbin:/bin:/sbin",
     onlyif => "dpkg -l puppet | grep 0.2"
}



file { "/etc/apt/preferences": ensure => present,
  owner => root,
  content => "#APT PINNING PREFERENCES
Package: *
Pin: release a=lenny-backports
Pin-Priority: 200
"
 }

