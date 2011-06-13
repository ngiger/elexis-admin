#
# postgres module
#
# Copyright 2008, Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#
# Module is base on the one from the immerda project
# https://git.puppet.immerda.ch/module-pgsql
# as well on Luke Kanies 
# http://github.com/lak/puppet-postgres/tree/master
#

class postgres {
  case $operatingsystem {
    centos: { include postgres::server::centos } 
    gentoo: { include postgres::server::gentoo } 
    default: { include postgres::server }
  }
  if $use_munin {
    include postgres::munin
  }
  if $use_shorewall {
    include shorewall::rules::postgres
  }
}
