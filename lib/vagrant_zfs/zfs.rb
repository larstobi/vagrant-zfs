require 'open3'
module VagrantZFS
  class ZFS
    def self.exec cmd
      cmd = "zfs " + cmd
      stdout, stderr, status = Open3.capture3(cmd)

      if status.success? and stderr.empty?
        return stdout
      else
        raise Exception, "ZFS Error: #{cmd}\n #{stdout}\n #{stderr}\n #{status}"
      end
    end

    def self.zpool_list
      `zpool list -H -o name`.split(/\n/)
    end

    def self.create fs_name, mountpoint
      cmd = "create -o mountpoint=#{mountpoint} #{fs_name}"
      self.exec cmd
    end

    def self.destroy fs_name
      cmd = "destroy #{fs_name}"
      self.exec cmd
    end

    def self.destroy_at mountpoint
        fs = VagrantZFS::ZFS.mounts.select do |mounted_at,fs|
            mounted_at == mountpoint
        end.first[1]
        puts "Will destroy #{fs} mounted at #{mountpoint}"
        self.destroy fs
    end

    def self.mounts
      cmd = "get -rHp -oname,value mountpoint"
      lines = self.exec(cmd).split(/\n/)
      mounts = lines.collect do |line|
        fs, path = line.chomp.split(/\t/, 2)
        [path, fs]
      end
      Hash[mounts]
    end

    def self.set_mountpoint fs_name, mountpoint
      cmd = "set mountpoint=#{mountpoint} #{fs_name}"
      self.exec cmd
    end

    def self.snapshot(fsname, snapname)
      #raise NotFound, "no such filesystem" if !exist?
      #raise AlreadyExists, "Snapshot #{snapname} already exists" if ZFS("#{fsname}@#{snapname}").exist?

      cmd = "snapshot #{fsname}@#{snapname}"
      self.exec cmd
      return "#{fsname}@#{snapname}"
    end

    def self.snapshot(fsname, snapname, opts={})
      #raise NotFound, "no such filesystem" if !exist?
      #raise AlreadyExists, "Snapshot #{snapname} already exists" if ZFS("#{fsname}@#{snapname}").exist?

      cmd = "snapshot #{fsname}@#{snapname}"
      self.exec cmd
      return "#{fsname}@#{snapname}"
    end

    # Clone snapshot
    def self.clone!(snapname, clonename)
      #clonename = clone.name if clone.is_a? ZFS
      #raise AlreadyExists if ZFS(clone).exist?

      cmd = "clone #{snapname} #{clonename}"
      self.exec cmd
    end
  end
end
