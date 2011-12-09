class  sudo::install {
  package{ "sudo":
  	ensure => installed,
  }
}
# class  { 'sudo::install': }
