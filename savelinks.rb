#!/usr/bin/ruby
require 'find'
Find.find('.') do |path|
  next unless File.symlink?(path)
  next if path =~ %r(/vendor/bundle/)
  next if path =~ %r(/node_modules/)
  linkdest = File.readlink(path)
  type = File.directory?(path) ? 'd' : 'f'
  path = path.sub(%r(^\./), '')
  puts "#{path}\t#{linkdest}\t#{type}"
end
