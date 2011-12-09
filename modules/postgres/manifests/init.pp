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
class postgres::common {
   case $operatingsystem {
      /Debian|Ubuntu/:  { $postgres_server_pkg = 'postgresql'
			  $postgres_cfg_path  = '/etc/postgresql/8.4/main'
			  $postgres_base_path = '/var/lib/postgresql/8.4/main'
			  $postgres_client_pkg = 'postgresql-client' }
      default:          { $postgres_server_pkg = 'postgresql-server'
			  $postgres_cfg_path = '/var/lib/pgsql/data' 
			  $postgres_base_path = '/var/lib/pgsql'
			  $postgres_client_pkg = 'postgresql'
                        }
    }  
}

class postgres {
  if $use_munin {
    include postgres::munin
  }
  if $use_shorewall {
    include shorewall::rules::postgres
  }
}
