node "elexis-vm-1"
{include sudo::install
    include  x2go::server
    include  elexis-db
  include x2go::client
  include elexis-kde
}
