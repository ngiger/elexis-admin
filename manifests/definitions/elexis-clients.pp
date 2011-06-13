class elexis-client {
    
    include postgres::client
    # TODO: create elexis package!!
  package{"sun-java6-jre":
    ensure => present,
  }
}