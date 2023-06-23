#cloud-config
write_files:
  # linux-generic, linux-virtual, linux-aws, linux-oracle, linux-azure, linux-gcp
  - path: /run/kernel-meta-package
    content: |
      linux-oracle
    owner: root:root
    permissions: "0644"
  - path: /tmp/grub-99-custom.cfg
    content: |
      GRUB_TIMEOUT_STYLE=menu
      GRUB_TIMEOUT=5
      GRUB_RECORDFAIL_TIMEOUT=$GRUB_TIMEOUT
      GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0"
      GRUB_CMDLINE_LINUX="net.ifnames=0 modprobe.blacklist=floppy nomodeset"
      GRUB_TERMINAL="console serial"
      GRUB_SERIAL_COMMAND="serial --speed=115200"
      GRUB_DISABLE_SUBMENU=y
      GRUB_DISABLE_RECOVERY=true
      GRUB_DISABLE_OS_PROBER=true
      GRUB_GFXPAYLOAD_LINUX=800x600
autoinstall:
  version: 1
  # interactive-sections:
  #   - source
  apt:
    preserve_sources_list: false
    primary:
      - arches: [default]
        uri: "http://archive.ubuntu.com/ubuntu"
    geoip: false
  refresh-installer:
    update: no
  identity:
    hostname: localhost
    realname: ${os_username}
    username: ${os_username}
    password: ${os_password_encrypted}
  ssh:
    allow-pw: false
    authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFOvXax9dNqU2unqd+AZQ+VSe2cZZbGMVRuzIW4Hl6Ji69R0zkWih0vuP2psRA/uWTg1XqFKisCp9Z1XQcBbH2WLhnIWhykeLOHtBdEQqUApKj+BrKnyDmBbCourUwAcuUQSRPeRBOg5hwReviIebwvELmwc8ab1r0X+nbCDwVdohTpwNnxHp5MTO0WADLdP0oDQy2hhVaiParCWdVvgfDauQ2IpgeN6tE5sUvsDyYLaYp/dIhddA/Dwh9sWEFfN7ERMSHJw/A/3GsQ49a8+w6lamgcfNDKK7hE9F5vn95fzhge0jj6Yl8NTXOzoMfpvPo3Q+uCbu+GRMlRAK3hcHP wilton.pem
    install-server: true
  # source:
  #   search_drivers: false
  #   id: ubuntu-server-minimized
  packages:
    - grub-pc-bin
    - tmux
  early-commands:
    # Disable SSH in the installer to avoid packer connecting to it
    - systemctl stop ssh
    # Minimal Ubuntu Server Image (ubuntu-server-minimal.squashfs)
    # This version has been customized to have a small runtime footprint in environments where humans are not expected to log in.
    # - cat /cdrom/casper/install-sources.yaml | awk 'NR>1 && /^-/{exit};1' > /run/my-sources.yaml
    # - mount -o ro,bind /run/my-sources.yaml /cdrom/casper/install-sources.yaml
  late-commands:
    - echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/99-sudo-nopasswd
    - |
      cp /tmp/grub-99-custom.cfg /target/etc/default/grub.d/99-custom.cfg
      curtin in-target -- update-grub
      curtin in-target -- grub-install --target=i386-pc /dev/sda
  shutdown: reboot
  # error-commands:
  #   - tail -n 500 /var/log/syslog | grep -E 'subiquity/Error' -B 100
  storage:
    swap:
      size: 0
    config:
    - {type: disk, id: sda, path: /dev/sda, ptable: gpt, wipe: superblock}
    - {type: partition, id: part1, device: sda, size: 1MB, flag: bios_grub, name: legacy}
    - {type: partition, id: part2, device: sda, size: 2GB, name: boot}
    - {type: partition, id: part3, device: sda, size: 100MB, flag: boot, name: uefi, grub_device: true}
    - {type: partition, id: part4, device: sda, size: -1, flag: lvm, name: lvm}
    - {type: lvm_volgroup, id: vg0, devices: [part4], name: vg0}
    - {type: lvm_partition, id: tmp, volgroup: vg0, size: 1GB, name: tmp}
    - {type: lvm_partition, id: var, volgroup: vg0, size: 4GB, name: var}
    - {type: lvm_partition, id: vartmp, volgroup: vg0, size: 1GB, name: vartmp}
    - {type: lvm_partition, id: varlog, volgroup: vg0, size: 2GB, name: varlog}
    - {type: lvm_partition, id: auditlog, volgroup: vg0, size: 1GB, name: auditlog}
    - {type: lvm_partition, id: home, volgroup: vg0, size: 2GB, name: home}
    - {type: lvm_partition, id: swap, volgroup: vg0, size: 1GB, name: swap}
    - {type: lvm_partition, id: root, volgroup: vg0, size: 4GB, name: root}
    - {type: format, id: part2_format, volume: part2, fstype: ext4, label: boot}
    - {type: format, id: part3_format, volume: part3, fstype: fat32, label: uefi}
    - {type: format, id: tmp_format, volume: tmp, fstype: ext4}
    - {type: format, id: var_format, volume: var, fstype: ext4}
    - {type: format, id: vartmp_format, volume: vartmp, fstype: ext4}
    - {type: format, id: varlog_format, volume: varlog, fstype: ext4}
    - {type: format, id: auditlog_format, volume: auditlog, fstype: ext4}
    - {type: format, id: home_format, volume: home, fstype: ext4}
    - {type: format, id: swap_format, volume: swap, fstype: swap}
    - {type: format, id: root_format, volume: root, fstype: ext4}
    - {type: mount, id: part2_mount, device: part2_format, path: /boot}
    - {type: mount, id: part3_mount, device: part3_format, path: /boot/efi}
    - {type: mount, id: tmp_mount, device: tmp_format, path: /tmp}
    - {type: mount, id: var_mount, device: var_format, path: /var}
    - {type: mount, id: vartmp_mount, device: vartmp_format, path: /var/tmp}
    - {type: mount, id: varlog_mount, device: varlog_format, path: /var/log}
    - {type: mount, id: auditlog_mount, device: auditlog_format, path: /var/log/audit}
    - {type: mount, id: home_mount, device: home_format, path: /home}
    - {type: mount, id: swap_mount, device: swap_format, path: none}
    - {type: mount, id: root_mount, device: root_format, path: /}