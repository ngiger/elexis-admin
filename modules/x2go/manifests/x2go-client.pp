class x2go::client   inherits x2go::common {


  package { "x2goclient":
    ensure => installed,
    require => Exec["x2go_apt_update"]
  }	

}