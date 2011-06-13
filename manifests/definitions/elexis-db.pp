class elexis-db {
  file{"/tmp/foo.conf":
    source => [
      "puppet:///foo/foo.conf",
    ],
    owner => elexis, group => elexis, mode => 0666;
  }
# gemäss beispiel http://docs.puppetlabs.com/guides/file_serving.html
  file{"/tmp/testfile.txt":
    source => [
      "puppet:///modules/test_module/testfile.txt",
    ],
    owner => elexis, group => elexis, mode => 0666;
  }
  file{"/tmp/pg_hba.conf":
    source => [
      "puppet:///modules/postgres/pg_hba.conf",
      "puppet:///modules/test_module/testfile.txt",
    ],
    owner => elexis, group => elexis, mode => 0666;
  }

# exec {"/usr/local/bin/ainsl /etc/ssh/sshd_config 'Port 8245'": }

# augeas does not work at the moment!!!


    include postgres::server
      postgres::database { "elexis-psql": ensure => present,
      owner => 'niklaus'
    }
}
