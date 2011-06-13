class postgres::client {
  package{'postgresql':
    ensure => present,
  }
  if $use_shorewall {
    include shorewall::rules::out::postgres
  }
}
