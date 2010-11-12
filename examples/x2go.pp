
exec {
"gpg --quiet --keyserver wwwkeys.eu.pgp.net --recv-keys C509840B96F89133 ; gpg -a --export C509840B96F89133 | sudo apt-key add -":
  path    => "/usr/bin:/usr/sbin:/bin:/sbin",
  unless  => "apt-key list | grep obviously-nice.de"
}	

file { "/etc/apt/sources.list.d/02_xg2o.list": ensure => present,
  owner   => root,
  content => "deb http://x2go.obviously-nice.de/deb/ lenny main\n"
 }

exec {
"aptitude update":
  path    => "/usr/bin:/usr/sbin:/bin:/sbin",
}	
package { "x2goserver-one":
   ensure => installed,
   # require => Package[openssl]
}	
