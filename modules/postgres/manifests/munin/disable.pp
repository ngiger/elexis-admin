class postgres::munin::disable inherits postgres::munin {
  Munin::Plugin::Deploy['pg_conn']{
    ensure => absent,
  }
}
