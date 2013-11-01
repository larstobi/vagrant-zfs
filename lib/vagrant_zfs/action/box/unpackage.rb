require 'archive/tar/minitar'
module VagrantZFS
  module Action
    module Box
      # Unpackages a downloaded box to a given directory with a given
      # name.
      #
      # This variant will first create a ZFS directory from a configured
      # zpool and then unpack the box into the directory.
      #
      # # Required Variables
      #
      # * `download.temp_path` - A location for the downloaded box. This is
      #   set by the {Download} action.
      # * `box` - A {Vagrant::Box} object.
      #
      class Unpackage
        attr_reader :box_directory

        def initialize(app, env)
          @logger   = Log4r::Logger.new("vagrant_zfs::action::box::unpackage")
          @app = app
          @env = env
        end

        def call(env)
          @env = env

          setup_box_directory
          decompress

          @app.call(@env)
        end

        def recover(env)
          if box_directory && File.directory?(box_directory)
            VagrantZFS::ZFS.destroy env[:zfs_name]
            FileUtils.rm_rf(box_directory)
          end
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

        def setup_box_directory
          if File.directory?(@env["box_directory"])
            raise Errors::BoxAlreadyExists, :name => @env["box_name"]
          end

          puts "ZPOOL: #{zpool}"
          @env[:zfs_name] = "#{zpool}/vagrant_#{@env["box_name"]}"
          mountpoint = "#{@env["box_directory"]}"
          VagrantZFS::ZFS.create @env[:zfs_name], mountpoint
          @box_directory = @env["box_directory"]
        end

        def decompress
          Dir.chdir(@env["box_directory"]) do
            @env[:ui].info I18n.t("vagrant.actions.box.unpackage.extracting")
            begin
              Archive::Tar::Minitar.unpack(@env["download.temp_path"], @env["box_directory"].to_s)
            rescue SystemCallError
              raise Errors::BoxUnpackageFailure
            end
          end
        end
      end
    end
  end
end
