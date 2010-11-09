user { "git":
	  ensure => "present",
	  home => "/var/git",
}

file {"/var/git": ensure => directory, owner => git, 
	require => User["git"];
	"/var/git/puppet": ensure => directory, owner => git, 
	require => [User["git"], File["/var/git"]],
}

package { "git":
	ensure => installed,
}

exec { "Create puppet Git repo":
	cwd => "/var/git/puppet",
	user => "git",
	unless => "/usr/bin/git status -s",
	command => "/usr/bin/git clone git://github.com/ngiger/elexis-admin.git .",
	creates => "/var/git/puppet/HEAD",
	require => [File["/var/git/puppet"], Package["git"], User["git"]],
}

# vi:syntax=puppet:filetype=puppet:ts=4:et:
