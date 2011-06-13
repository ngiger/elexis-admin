class postgres::munin {
  munin::plugin::deploy{'pg_conn': 
    source => 'postgres/munin/pg_conn',
  }
  munin::plugin::deploy{'pg__connections': 
    ensure => absent,
    source => 'postgres/munin/pg__connections',
  }
  munin::plugin::deploy{'pg__locks': 
    ensure => absent,
    source => 'postgres/munin/pg__locks',
  }
}
