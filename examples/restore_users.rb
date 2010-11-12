#!/usr/bin/env ruby
Users  = [ 'belgica', 'bruno', 'testelexis']
Backup = '/mnt/share/cosre'

require 'fileutils'

Users.each { |u|
  puts u
  dir="#{Backup}/home/#{u}"
  dest="/home/"
  puts dir
  puts dest
  puts File.directory?(dir)
  puts File.directory?(dest)
  FileUtils.cp_r(dir, dest, { :verbose => true, :preserve => true})
  FileUtils.chown_R(u, 'elexis', "#{dest}/#{u}")
}
