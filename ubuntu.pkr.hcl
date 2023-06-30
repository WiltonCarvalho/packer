locals {
  data_source_content = {
    "/meta-data" = file("${abspath(path.root)}/cidata/meta-data")
    "/user-data" = templatefile("${abspath(path.root)}/cidata/user-data.pkrtpl.hcl", {
      os_username           = var.os_username
      os_password_encrypted = var.os_password_encrypted
      ssh_public_key        = var.ssh_public_key
    })
  }
  data_source_command = "ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\""
}
source "qemu" "ubuntu" {
  iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso"
  iso_checksum     = "file:https://releases.ubuntu.com/22.04/SHA256SUMS"
  output_directory = "output"
  shutdown_command = "sudo shutdown -P now"
  disk_size        = "20G"
  format           = "qcow2"
  accelerator      = "kvm"
  headless         = "false"
  #http_directory       = "cidata"
  http_content = "${local.data_source_content}"
  // cd_content = {
  //   "meta-data" = file("${abspath(path.root)}/my-meta-data")
  //   "user-data" = file("${abspath(path.root)}/my-user-data")
  // }
  cd_label             = "cidata"
  ssh_username         = "${var.os_username}"
  ssh_private_key_file = "${var.ssh_private_key_file}"
  ssh_timeout          = "30m"
  vm_name              = "${var.vm_name}.qcow2"
  net_device           = "virtio-net"
  disk_interface       = "virtio-scsi"
  cdrom_interface      = "virtio-scsi"
  boot_wait            = "10s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall net.ifnames=0 modprobe.blacklist=floppy ${local.data_source_command}",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  qemuargs = [
    ["-bios", "OVMF.fd"],
    ["-device", "virtio-scsi-pci"],
    ["-device", "scsi-hd,drive=drive0,bootindex=0"],
    ["-device", "scsi-cd,drive=cdrom0,bootindex=1"],
    ["-cpu", "host"],
    ["-m", "1024M"],
    ["-smp", "2"]
  ]
}

build {
  sources = ["source.qemu.ubuntu"]
  provisioner "file" {
    source      = "ubuntu_oci_rules.v4"
    destination = "/tmp/ubuntu_oci_rules.v4"
  }
  provisioner "file" {
    source      = "ubuntu_oci_pkgs.txt"
    destination = "/tmp/ubuntu_oci_pkgs.txt"
  }
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apt-get update",
      #"apt-get --yes install ec2-instance-connect",
      #"apt-get --yes install open-vm-tools",
      "apt-get --yes install qemu-guest-agent dselect",
      "dselect update",
      "dpkg --set-selections < /tmp/ubuntu_oci_pkgs.txt",
      "DEBIAN_FRONTEND=noninteractive apt-get -y dselect-upgrade",
      "apt-get --yes dist-upgrade",
      "apt-get --yes autoremove",
      "apt-get clean",
      "mv /tmp/ubuntu_oci_rules.v4 /etc/iptables/rules.v4",
      #"snap install amazon-ssm-agent --classic",
      "snap install oracle-cloud-agent --classic",
      "truncate -s 0 /etc/machine-id",
      "truncate -s 0 /var/lib/dbus/machine-id",
      "rm -f /home/ubuntu/.ssh/authorized_keys",
      "rm -f /etc/netplan/00-installer-config.yaml",
      "rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg",
      "rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "rm -f /etc/cloud/cloud.cfg.d/curtin-preserve-sources.cfg",
      "rm -f /etc/ssh/sshd_config.d/50-cloud-init.conf",
      "sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config",
      "cloud-init clean"
    ]
  }
  // post-processor "vagrant" {
  //   compression_level   = 6
  //   keep_input_artifact = true
  //   output              = "output/${var.vm_name}.box"
  //   //vagrantfile_template = "vagrant.rb.j2"
  // }
}
# oci os object put -bn images --file output/ubuntu.qcow2
# oci compute image import from-object --bucket-name images --compartment-id $OCI_CID --namespace $OCI_NS --operating-system $OS_TYPE \
# --operating-system-version $OS_VERSION --source-image-type QCOW2 --display-name $IMAGE --name $IMAGE