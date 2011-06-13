class elexis-kde {

#   elexis on a KDE
    include elexis-client
  package{"kde-plasma-desktop":
    ensure => present,
  }
}
