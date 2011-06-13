class ainsl {
# Handy perl script for AppendIfNoSuchLine utility

  file{"/usr/local/bin/ainsl":
    source => [
      "puppet:///manifests/files/ainnsl",
    ],
    require => Package["perl"],
    owner => root, group => postgres, root => 0755;
  }

}