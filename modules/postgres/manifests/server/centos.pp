class postgres::server::centos inherits postgres::server {
  package{'ruby-postgres':
    ensure => installed
  }
}
