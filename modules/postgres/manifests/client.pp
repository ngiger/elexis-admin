class postgres::client inherits postgres::common  {
  package{$postgres_client_pkg:
    ensure => present,
  }
  if $use_shorewall {
    include shorewall::rules::out::postgres
  }
}
