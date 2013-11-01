Gem::Specification.new do |s|
  s.name        = 'vagrant-zfs-box'
  s.version     = '0.0.2'
  s.date        = '2013-03-18'
  s.summary     = "ZFS plugin for Vagrant 1.0"
  s.description = "ZFS plugin that uses snapshots and clones to speed up box creation for Vagrant 1.0"
  s.authors     = ["Lars Tobias Skjong-Borsting"]
  s.email       = 'larstobi@conduct.no'
  s.files       = [
    'LICENSE',
    'README.md',
    'lib/vagrant/downloaders/file.rb',
    'lib/vagrant_init.rb',
    'lib/vagrant_zfs.rb',
    'lib/vagrant_zfs/actions.rb',
    'lib/vagrant_zfs/actions/box/destroy.rb',
    'lib/vagrant_zfs/actions/box/unpackage.rb',
    'lib/vagrant_zfs/actions/vm/destroy.rb',
    'lib/vagrant_zfs/actions/vm/import.rb',
    'lib/vagrant_zfs/vboxmanage.rb',
    'lib/vagrant_zfs/version.rb',
    'lib/vagrant_zfs/zfs.rb',
    'lib/vagrant_zfs/zfs_config.rb',
    'vagrant-zfs-box.gemspec']
  s.homepage    =
    'http://rubygems.org/gems/vagrant-zfs-box'
end
