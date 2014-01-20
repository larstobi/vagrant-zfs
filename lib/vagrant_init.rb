I18n.enforce_available_locales = true
begin
  require 'vagrant_zfs'
rescue LoadError
  require 'rubygems'
  require 'vagrant_zfs'
end
