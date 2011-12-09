class x2go::server   inherits x2go::common {

  package { "x2goserver-one":
    ensure => installed,
    require => [ Package[openssl,gnupg], Exec["x2go_apt_update"] ]
  }
}
