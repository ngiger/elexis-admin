class postgres::server inherits postgres::common {
  include postgres::client

# debian uses /etc/postgresql/<version>/  
  package{$postgres_server_pkg:
    ensure => present,
  }
  service{'postgresql':
    enable => true,
    ensure => running,
    hasstatus => true,
    require => Package[$postgres_server_pkg],
  }
  exec{'initialize_postgres_database':
    command => '/etc/init.d/postgresql start; /etc/init.d/postgresql stop',
    creates => "${$postgres_base_path}/postgresql.conf",
    require => Package[$postgres_server_pkg],
    before => [
#      File["${postgres_cfg_path}/pg_hba.conf"], 
#      File["${postgres_cfg_path}/postgresql.conf"]
    ],
  }
  file{"${postgres_cfg_path}/postgresql.conf.puppet":
    source => [
      "puppet:///modules/site-postgres/${fqdn}/postgresql.conf",
      "puppet:///modules/site-postgres/postgresql.conf",
      "puppet:///modules/postgres/postgresql.conf.${operatingsystem}",
      "puppet:///modules/postgres/postgresql.conf"
    ],
    notify => Service[postgresql],
    require => Package[$postgres_server_pkg],
    owner => postgres, group => postgres, mode => 0600;
  }
  file{"${postgres_cfg_path}/pg_hba.conf.puppet":
    source => [
      "puppet:///modules/site-postgres/${fqdn}/pg_hba.conf",
      "puppet:///modules/site-postgres/pg_hba.conf",
      "puppet:///modules/postgres/pg_hba.conf.${operatingsystem}",
      "puppet:///modules/postgres/pg_hba.conf"
    ],
    notify => Service[postgresql],
    require => Package[$postgres_server_pkg],
    owner => postgres, group => postgres, mode => 0600;
  }

  file{"${postgres_base_path}/backups":
    ensure => directory,
    require => Package[$postgres_server_pkg],
    recurse => true,
    owner => postgres, group => postgres, mode => 0700;
  }
  file{'/etc/cron.d/pgsql_backup.cron.puppet':
    source => "puppet:///modules/postgres/pgsql_backup.cron",
    require => File["${$postgres_base_path}/backups"],
    owner => root, group => 0, mode => 0600;
  }
  file{'/etc/cron.d/pgsql_vacuum.cron.puppet':
    source => "puppet:///modules/postgres/pgsql_vacuum.cron",
    require => Package[$postgres_server_pkg],
    owner => root, group => 0, mode => 0600;
  }
}
