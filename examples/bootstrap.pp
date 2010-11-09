user { "git":
	  ensure => "present",
	  home => "/var/git",
}

file {"/var/git": ensure => directory, owner => git, 
	require => User["git"];
	"/var/git/puppet": ensure => directory, owner => git, 
	require => [User["git"], File["/var/git"]],
}

ssh_authorized_key { "git":
	ensure => present,
	key => "INSERT PUBLIC KEY HERE",
	name => "git@atalanta-systems.com",
	target => "/var/git/.ssh/authorized_keys",
	type => rsa,
	require => File["/var/git"],
}

yumrepo { "elexis-admin":
	baseurl => "git://github.com/ngiger",
	descr => "Elexis admin made easy",
	enabled => 1,
	gpgcheck => 0,
	name => "elexis-admin",
}

package { "git":
	ensure => installed,
	require => Yumrepo["elexis-admin"],
}

exec { "Create puppet Git repo":
	cwd => "/var/git/puppet",
	user => "git",
	command => "/usr/bin/git init --bare",
	creates => "/var/git/puppet/HEAD",
	require => [File["/var/git/puppet"], Package["git"], User["git"]],
}

