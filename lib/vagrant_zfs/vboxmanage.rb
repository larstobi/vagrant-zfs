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

    def self.gethduuid file
      # I found the line number may be 23, but search 40 just to be sure.
      cmd="head -n 40 #{file}|grep --text --byte-offset --max-count=1 ddb.uuid.image="
      stdout, stderr, status = Open3.capture3(cmd)
      unless status.success? and stderr.empty?
        raise Exception, "gethduuid Error: #{cmd}\n #{stdout}\n #{stderr}\n #{status}"
      end
      # UUID format is a string of hyphen-punctuated character groups of 8-4-4-4-12.
      uuid = stdout.match(/ddb.uuid.image="(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})"/).captures.first
    end

    def self.sethduuid_shell file
      # I found the line number may be 23, but search 40 just to be sure.
      cmd="head -n 40 #{file}|grep --text --byte-offset --max-count=1 ddb.uuid.image="
      stdout, stderr, status = Open3.capture3(cmd)
      unless status.success? and stderr.empty?
        raise Exception, "gethduuid Error: #{cmd}\n #{stdout}\n #{stderr}\n #{status}"
      end
      # The number before : is the byte offset number.
      byte_offset = stdout.split(':').first.to_i
      name_length = 'ddb.uuid.image="'.length

      uuid_offset = byte_offset + name_length
      uuid_length = 36

      stdout, stderr, status = Open3.capture3("uuidgen")
      unless status.success? and stderr.empty?
        raise Exception, "gethduuid Error: #{cmd}\n #{stdout}\n #{stderr}\n #{status}"
      end
      new_uuid = stdout.chomp

      # Edit file in place.
      cmd = "echo #{new_uuid} | dd of=#{file} seek=#{uuid_offset} bs=1 count=#{uuid_length} conv=notrunc"
      `#{cmd}` ? new_uuid : nil
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
      uuid_pre  = self.gethduuid(hddfile)
      self.sethduuid hddfile
      uuid_post = self.gethduuid(hddfile)

      # Did self.sethduuid work?
      unless uuid_pre != uuid_post
        puts "VBoxManage internalcommands sethduuid did not work. Trying shell with dd"
        self.sethduuid_shell hddfile
        uuid_post = self.gethduuid(hddfile)
        unless uuid_pre != uuid_post
          puts "Did not succeed to sethduuid."
        end
      end

      self.add_storagectl uuid
      self.add_disk       uuid, hddfile
      self.add_nat        uuid
      self.cpus           uuid, "1"
      self.memory         uuid, "512"
    end
  end
end
