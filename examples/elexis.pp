package { "sun-java5-jre":
   ensure => purged,
}	
package {[ "sun-java6-jre", "sun-java6-bin"]:
   ensure => installed,
}	
file { "/home/belgica/Desktop/elexis":
  ensure => "/usr/local/bin/elexis",
  owner => 'belgica',
  mode  => '755',
}
exec{ "update-alternatives --set java /usr/lib/jvm/java-6-sun/jre/bin/java":
  creates => '/etc/alternatives/java',
  path    => "/usr/bin:/usr/sbin:/bin:/sbin",
}

file { "/usr/bin/java":
  ensure => "/etc/alternatives/java",
  owner => 'belgica',
  mode  => '755',
}
