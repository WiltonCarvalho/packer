# Build KVM Image
packer fmt ubuntu.pkr.hcl
packer build .


# Test in KVM
cloud-localds /tmp/my-seed.img my-user-data my-meta-data
kvm -cpu host -smp 2 -m 1024m \
  -net nic -net user,hostfwd=tcp::2222-:22 \
  -drive file=output/ubuntu.qcow2,format=qcow2,if=virtio \
  -drive file=/tmp/my-seed.img,format=raw,if=virtio \
  --nographic
ssh -p 2222 ubuntu@localhost

# Cloud-init SysPrep
truncate -s 0 /etc/machine-id
truncate -s 0 /var/lib/dbus/machine-id
rm -f /etc/netplan/50-cloud-init.yaml
rm -f /etc/ssh/sshd_config.d/50-cloud-init.conf
rm -f /home/ubuntu/.ssh/authorized_keys
cloud-init clean


# Test Vagrant
sudo apt install libvirt-dev vagrant
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-env
vagrant box add test output/ubuntu.box
vagrant box list

cloud-localds /tmp/my-seed.img my-user-data my-meta-data
vagrant up
vagrant ssh
vagrant destroy