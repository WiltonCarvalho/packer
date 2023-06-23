packer fmt ubuntu.pkr.hcl
packer build .

sudo ip tuntap add tap0 mode tap user $USER
sudo brctl addif virbr0 tap0

kvm -cpu host -smp 2 -m 1024m -net nic,model=virtio -net tap,ifname=tap0 -drive file=output/ubuntu.qcow2,format=qcow2,if=virtio --nographic
