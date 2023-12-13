variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

source "proxmox" "worker-node" {

  proxmox_url = "${var.proxmox_api_url}"
  username = "${var.proxmox_api_token_id}"
  token = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true

  node = "pve"
  vm_id = "200"
  vm_name = "worker-node"
  template_description = "Template for cluster worker node"

  cores = "2"
  memory = "8192"
  os = "l26"

  iso_file = "local:iso/ubuntu.iso"
  iso_storage_pool = "local"
  cloud_init_storage_pool = "local-lvm"

  cloud_init = true
  unmount_iso = true
  qemu_agent = true

  disks {
    type = "scsi"
    disk_size = "20G"
    storage_pool = "local-lvm"
    storage_pool_type = "lvm"
  }

  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
    firewall = false
  }

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot = "c"
  boot_wait = "5s"

  http_directory = "http"
  http_bind_address = "192.168.1.14"
  http_port_min = 12222
  http_port_max = 12222

  ssh_username = "simmondobber"
  ssh_private_key_file = "~/.ssh/packer"
  ssh_password = "Guy6672kor1"
  ssh_timeout = "1000m"
  ssh_pty = true
}

build {

  name = "worker-node"
  sources = ["source.proxmox.worker-node"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "echo 'Guy6672kor1' | sudo -S whoami",
      "sudo rm -rf /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -rf /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync",
    ]
  }

  provisioner "file" {
    source = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = [
      "echo 'Guy6672kor1' | sudo -S whoami",
      "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"
    ]
  }
}