node "elexis-vm-2"
{
  include sudo::install
  include x2go::client
  include elexis-kde
}
