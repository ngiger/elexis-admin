class postgres::disable inherits postgres::server {
  Service['postgresql']{
    ensure => stopped,
    enable => false,
  }
  File[ '/etc/cron.d/pgsql_backup.cron', '/etc/cron.d/pgsql_vacuum.cron' ]{
    ensure => absent,
  }
  if $use_munin {
    include postgres::munin::disable
  }
}
