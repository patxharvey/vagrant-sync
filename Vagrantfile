Vagrant.configure("2") do |config|
  # Specify Box
  config.vm.box = "gyptazy/ubuntu22.04-arm64"
  # Agent forwarding
  config.ssh.forward_agent = true
  # Specify Sync
  config.vm.synced_folder ".", "/home/vagrant/bin"
  config.vm.synced_folder "/Users/pharvey/dev/media-backup-vagrant", "/home/vagrant/media-backup-vagrant"
  # Set a private network with a specific IP
  config.vm.network "private_network", ip: "192.168.28.128"
  # Forward port 2222 on the host to port 22 on the VM
  config.vm.network "forwarded_port", guest: 22, host: 12345
end

