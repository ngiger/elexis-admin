node "elexis-admin" {
#  include postgres::server
  file{"/tmp/foo.conf":
    source => [
      "puppet:///foo/foo.conf",
    ],
    owner => elexis, group => elexis, mode => 0666;
  }
}

