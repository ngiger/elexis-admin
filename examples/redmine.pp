#  By default, redmine admin account log/pass is admin/admin
# dpkg-reconfigure -plow redmine 
# TODO: ensure that /etc/auto.master contains the following two lines
# +auto.master
# /net    -hosts

package { "nginx":
   ensure => installed,
}

package { "autofs5":
   ensure => installed,
}

package { "redmine-pgsql":
   ensure => installed,
}

package { "postgresql-8.4":
   ensure => installed,
}

package { "redmine":
   ensure => installed,
   require => Package['postgresql-8.4',redmine-pgsql,nginx,autofs5],
}

file { "/etc/redmine/default": ensure => present,
  owner => root,
  content => '
production:
   delivery_method: :sendmail

'
}
file { "/etc/redmine/default/database.yml": 
  ensure  => present,
  owner   => root,
  mode    => '600',
  content => '
production:
  adapter: postgresql
  database: redmine_default
  host: localhost
  port: 
  username: redmine
  password: TZd3LUXXiEkk
  encoding: utf8
'
}

file { "/etc/redmine/default/session.yml": 
  ensure  => present,
  owner   => root,
  mode    => '600',
  content => '
production:
  key: _redmine_default
  secret: dac091f1bf38fde9f431e3adc267ae0cdc848b60f2623525d7a841aa43c35048cc620da921daa7de

development:
  key: _redmine_default
  secret: dac091f1bf38fde9f431e3adc267ae0cdc848b60f2623525d7a841aa43c35048cc620da921daa7de

test:
  key: _redmine_default
  secret: dac091f1bf38fde9f431e3adc267ae0cdc848b60f2623525d7a841aa43c35048cc620da921daa7de
',
}


file { "/etc/cron.daily/backup_redmine": 
  ensure  => present,
  owner   => root,
  mode    => '700',
  content => '#!/bin/dash -v
# Simple backup script for my redmine installation
# idea came from http://www.redmine.org/wiki/1/RedmineInstall
# User must have a .pgpass file with the correct password!!
# Niklaus Giger, 28.09.2010
#
# Database
BACKUP_PATH=/net/fest/nfs4exports/backup/backup.redmine
if [ -d $BACKUP_PATH ]
then
  mkdir -p $BACKUP_PATH/files
  sudo -u redmine /usr/bin/pg_dump -U redmine --no-password redmine_cosre | gzip > $BACKUP_PATH/redmine_`date +%y_%m_%d`.gz

# restore withzcat /net/fest/nfs4exports/backup/backup.redmine/redmine.gz| sudo -u www-data /usr/bin/psql
  # Attachments
  sudo rsync -a /var/lib/redmine/ $BACKUP_PATH/files
  logger "redmine backup on $BACKUP_PATH done"
else
  logger "redmine backup failed"
fi
'
}
