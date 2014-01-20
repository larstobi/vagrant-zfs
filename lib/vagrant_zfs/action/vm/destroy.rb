module VagrantZFS
  module Action
    module VM
      class Destroy
        def initialize(app, env)
          @logger   = Log4r::Logger.new("vagrant_zfs::action::vm::destroy")
          @app = app
        end

        def zpool
          # Is the zpool specified in the Vagrantfile?
          if @env['global_config'].zfs.zpool
            @env['global_config'].zfs.zpool
          else
            # If we have only one zpool available, go with that.
            zpools = VagrantZFS::ZFS.zpool_list
            if zpools.length == 1
              zpools.first
            else
              raise Exception, "zpool not specified and more than one available."
            end
          end
        end

        def call(env)
          @env = env
          env[:ui].info I18n.t("vagrant.actions.vm.destroy.destroying")

          cmd = "VBoxManage showvminfo #{env[:vm].uuid}"
          stdout, stderr, status = Open3.capture3(*cmd)
          if status.success? and stderr.empty?
            instance_name = stdout.lines.grep(/^Name:\s*(.+)/){$1}.first
          else
            raise Exception, "Could not find instance name for VM #{env[:vm].uuid}"
          end

          puts "ZPOOL: #{zpool}"
          fs         = "#{zpool}/vagrant_#{env[:vm].config.vm.box}"
          clonename    = "#{fs}/#{instance_name}"
          snapname     = "#{fs}@#{instance_name}"

          env[:vm].driver.delete
          env[:vm].uuid = nil

          VagrantZFS::ZFS.destroy clonename
          VagrantZFS::ZFS.destroy snapname


          @app.call(env)
        end
      end
    end
  end
end
