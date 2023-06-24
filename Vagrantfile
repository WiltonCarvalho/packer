Vagrant.configure("2") do |config|
  config.vm.box = "test"
  config.vm.define "test"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.hostname = "test"
  config.ssh.username = 'ubuntu'
  #config.ssh.password = 'passw0rd'
  config.ssh.insert_key = false
  config.ssh.private_key_path = ['~/secrets/wilton.pem']
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 2
    libvirt.cpu_mode = 'host-passthrough'
    libvirt.memory = 1024
    libvirt.nested = true
    libvirt.storage :file, :device => :cdrom, :path => '/tmp/my-seed.img'
  end
end
