#!/usr/bin/ruby
require 'fileutils'
require 'find'
link_info = {}
ARGF.each_line do |line|
  line.chomp!
  link, dest, type = line.split("\t")
  if link.nil? || link.empty? || link =~ %r{(^|/)\.\.(/|$)}
    puts "format error: #{line}"
    exit 1
  end
  if type.nil? || type.empty?
    puts "format error: #{line}"
    exit 1
  end
  link_info[link] = dest
  if File.symlink?(link)
    if dest != File.readlink(link)
      puts "delete symlink: #{link} -> #{File.readlink(link)}"
      File.unlink(link)
    end
  elsif File.file?(link)
    puts "delete regular file: #{link}"
    File.unlink(link)
  elsif File.exist?(link)
    puts "delete directory: #{link}"
    FileUtils.remove_entry(link)
  end
  unless File.exist?(link) || File.symlink?(link)
    puts "create symlink: #{link} -> #{dest}"
    linkdir = File.dirname(link)
    FileUtils.mkpath(linkdir) unless File.exist?(linkdir)
    File.symlink(dest, link)
  end
end
Find.find('.') do |path|
  next if !File.symlink?(path)
  next if path =~ %r(/vendor/bundle/)
  next if path =~ %r(/node_modules/)
  path = path.sub(%r(^\./), '')
  unless link_info.key?(path)
    puts "delete symlink: #{path}"
    File.unlink(path)
  end
end
