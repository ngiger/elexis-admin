class elexis-db {

# schoebu hatt noch folgende Datei:
# /etc/postgresql/postgresql.env
# [ -r /etc/postgresql/postmaster.conf ] &&
#         . /etc/postgresql/postmaster.conf
# PGDATA=${POSTGRES_DATA:-/var/lib/postgres/data}
# PGLIB=/usr/lib/postgresql/lib
# PGACCESS_HOME=/usr/lib/postgresql/share/pgaccess
# PGHOST=
# export PGLIB PGDATA PGACCESS_HOME PGHOST

# TODO: - PGDATA fehlt beim Starten? (Von Hand mal gemäss Debian Drehbuch eine DB einrichten?
#        -pg_hba.conf via augeas oder @ directive um archive und hosts erweitern 
#        - Welche Benutzername/Passwoerter wurden gebraucht?
    include postgres::server
#      postgres::database { "elexis-psql": ensure => present, owner => 'niklaus' }
}
