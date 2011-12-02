node ng-hp	{include sudo::install

  file{"/tmp/foo.conf":
    source => [
      "puppet:///foo/foo.conf",
    ],
    owner => niklaus, group => niklaus, mode => 0666;
  }

    include  x2go::client
    include postgres::client
    include postgres::server
      postgres::database { "elexis-psql": ensure => present,
      owner => 'niklaus'
    }
}

