require 'open3'
module VagrantZFS
  class VBoxManage
    def self.exec cmd
      cmd = "VBoxManage " + cmd
      stdout, stderr, status = Open3.capture3(cmd)

      if status.success? and stderr.empty?
        return stdout
      else
        raise Exception, "VBoxManage Error: #{cmd}\n #{stdout}\n #{stderr}\n #{status}"
      end
    end

    def self.createvm instance_name, instance_root
      cmd = "createvm --name #{instance_name} --register --basefolder #{instance_root}"
      lines = self.exec(cmd).split(/\n/)
      uuid = lines.grep(/^UUID:\s*([-0-9a-z]+)/){$1}.first
    end

    def self.modifyvm uuid, arg
      self.exec "modifyvm #{uuid} #{arg}"
    end

    def self.add_nat uuid
      self.modifyvm  uuid, "--nic1 nat"
    end

    def self.cpus uuid, cpus
      self.modifyvm  uuid, "--cpus #{cpus}"
    end

    def self.memory uuid, memory
      self.modifyvm uuid, "--memory #{memory}"
    end

    def self.sethduuid file
      self.exec "internalcommands sethduuid #{file}"
    end

    def self.add_storagectl uuid
      self.exec "storagectl #{uuid} --name 'SATA Controller' --add sata --controller IntelAHCI --sataportcount 4 --hostiocache on  --bootable on"
    end

    def self.add_disk uuid, hddfile
      self.exec "storageattach #{uuid} --storagectl 'SATA Controller' --port 0 --type hdd --nonrotational on --medium #{hddfile}"
    end

    def self.setup uuid, hddfile
      self.sethduuid      hddfile
      self.add_storagectl uuid
      self.add_disk       uuid, hddfile
      self.add_nat        uuid
      self.cpus           uuid, "1"
      self.memory         uuid, "512"
    end
  end
end
