module VagrantZFS
  VERSION = "0.0.2"
end

require 'vagrant'
require 'vagrant/action/builder'
require 'vagrant_zfs/zfs_config'
require 'vagrant_zfs/zfs'
require 'vagrant_zfs/vboxmanage'
require 'vagrant_zfs/action'
require 'vagrant_zfs/version'

Vagrant.config_keys.register(:zfs) { ZfsConfig }
Vagrant.actions[:box_remove].replace(Vagrant::Action::Box::Destroy, VagrantZFS::Action::Box::Destroy)
Vagrant.actions[:box_add].replace(Vagrant::Action::Box::Unpackage, VagrantZFS::Action::Box::Unpackage)
Vagrant.actions[:up].delete(Vagrant::Action::VM::DefaultName)
Vagrant.actions[:up].replace(Vagrant::Action::VM::Import, VagrantZFS::Action::VM::Import)
Vagrant.actions[:destroy].replace(Vagrant::Action::VM::Destroy, VagrantZFS::Action::VM::Destroy)
