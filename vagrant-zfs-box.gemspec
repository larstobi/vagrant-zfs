Gem::Specification.new do |s|
  s.name        = 'vagrant-zfs-box'
  s.version     = '0.0.3'
  s.date        = '2014-01-20'
  s.summary     = "ZFS plugin for Vagrant 1.0"
  s.description = "ZFS plugin that uses snapshots and clones to speed up box creation for Vagrant 1.0"
  s.authors     = ["Lars Tobias Skjong-Borsting"]
  s.email       = 'larstobi@conduct.no'
  s.extra_rdoc_files = %w[README.md LICENSE vagrant-zfs-box.gemspec]
  s.files       = %w[
lib/vagrant/downloaders/file.rb
lib/vagrant_init.rb
lib/vagrant_zfs/action/box/destroy.rb
lib/vagrant_zfs/action/box/unpackage.rb
lib/vagrant_zfs/action/vm/destroy.rb
lib/vagrant_zfs/action/vm/import.rb
lib/vagrant_zfs/action.rb
lib/vagrant_zfs/vboxmanage.rb
lib/vagrant_zfs/zfs.rb
lib/vagrant_zfs/zfs_config.rb
lib/vagrant_zfs.rb
  ]
  s.homepage    =
    'http://rubygems.org/gems/vagrant-zfs-box'
end
