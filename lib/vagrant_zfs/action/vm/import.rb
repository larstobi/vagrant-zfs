module VagrantZFS
  module Action
    module VM
      class Import
        def initialize(app, env)
          @logger   = Log4r::Logger.new("vagrant_zfs::action::vm::import")
          @env = env
          @app = app
        end

        def find_basebox_filesystem
          fs = VagrantZFS::ZFS.mounts.select do |mountpoint,fs|
            mountpoint == @env[:vm].box.directory.to_s
          end.first[1]
          @logger.debug "Found base box filesystem: #{fs}"
          fs
        end

        def call(env)
          env[:ui].info I18n.t("vagrant.actions.vm.import.importing", :name => env[:vm].box.name)

          # Import the virtual machine
          ovf_file = env[:vm].box.directory.join("box.ovf").to_s

          fs = find_basebox_filesystem

          instance_name = env[:root_path].basename.to_s + "_#{Time.now.to_i}"
          env[:name] = instance_name

          VagrantZFS::ZFS.snapshot fs, instance_name

          user_home = ENV['HOME']
          vagrant_home = "#{user_home}/.vagrant.d"
          instance_root = vagrant_home + "/instances"

          clonename = "#{fs}/#{instance_name}"
          mountpoint = "#{instance_root}/#{instance_name}"
          VagrantZFS::ZFS.clone! "#{fs}@#{instance_name}", clonename
          VagrantZFS::ZFS.set_mountpoint clonename, mountpoint

          env[:vm].uuid = VagrantZFS::VBoxManage.createvm instance_name, instance_root
          hdd = instance_root + "/" + instance_name + "/box-disk1.vmdk"
          VagrantZFS::VBoxManage.setup env[:vm].uuid, hdd

          # # If we got interrupted, then the import could have been
          # # interrupted and its not a big deal. Just return out.
          # return if env[:interrupted]

          # Flag as erroneous and return if import failed
          raise Errors::VMImportFailure if !env[:vm].uuid

          # # Import completed successfully. Continue the chain
          @app.call(env)
        end

        def recover(env)
          if env[:vm].created?
            return if env["vagrant.error"].is_a?(Errors::VagrantError)

            # Interrupted, destroy the VM. We note that we don't want to
            # validate the configuration here.
            destroy_env = env.clone
            destroy_env[:validate] = false
            env[:action_runner].run(:destroy, destroy_env)
          end
        end
      end
    end
  end
end
