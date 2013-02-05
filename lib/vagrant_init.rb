begin
  require 'vagrant_zfs'
rescue LoadError
  require 'rubygems'
  require 'vagrant_zfs'
end
