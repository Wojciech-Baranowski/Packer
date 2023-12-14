variable "proxmox_api_token_id" {
  type = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

variable "ssh_password" {
  type = string
  sensitive = true
}

variable "vm_password" {
  type = string
  sensitive = true
}

variable "proxmox_api_address" {
  type = string
  default = "192.168.1.78"
}

variable "vm_id" {
  type = number
  default = 200
}

variable "vm_name" {
  type = string
  default = "worker-node"
}

variable "vm_description" {
  type = string
  default = "Template for cluster worker node"
}

variable "vm_cores" {
  type = number
  default = 2
}

variable "vm_memory" {
  type = number
  default = 8192
}

variable "iso_file" {
  type = string
  default = "ubuntu.iso"
}

variable "provisioning_server_address" {
  type = string
  default = "192.168.1.14"
}

variable "provisioning_server_port_range_min" {
  type = number
  default = 12222
}

variable "provisioning_server_port_range_max" {
  type = number
  default = 12232
}

variable "ssh_username" {
  type = string
  default = "simmondobber"
}

variable "ssh_timeout" {
  type = string
  default = "60m"
}

variable "disk_size" {
  type = string
  default = "20G"
}


source "proxmox" "ubuntu-build" {

  #proxmox connection
  proxmox_url = "https://${var.proxmox_api_address}:8006/api2/json"
  username = "${var.proxmox_api_token_id}"
  token = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true

  #virtual machine
  node = "pve"
  vm_id = "${var.vm_id}"
  vm_name = "${var.vm_name}"
  template_description = "${var.vm_description}"

  #hardware
  cores = "${var.vm_cores}"
  memory = "${var.vm_memory}"

  #iso
  iso_file = "local:iso/${var.iso_file}"
  iso_storage_pool = "local"
  unmount_iso = true

  #provisioning server
  http_directory = "http"
  http_bind_address = "${var.provisioning_server_address}"
  http_port_min = "${var.provisioning_server_port_range_min}"
  http_port_max = "${var.provisioning_server_port_range_max}"

  #cloud init
  cloud_init_storage_pool = "local-lvm"
  cloud_init = true
  qemu_agent = true

  #cloud-init ssh
  ssh_username = "${var.ssh_username}"
  #ssh_private_key_file = "~/.ssh/packer"
  ssh_password = "${var.ssh_password}"
  ssh_timeout = "${var.ssh_timeout}"
  ssh_pty = true

  #storage
  disks {
    type = "scsi"
    disk_size = "${var.disk_size}"
    storage_pool = "local-lvm"
    storage_pool_type = "lvm"
  }

  #network
  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
    firewall = false
  }

  #autoinstall
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
}

build {

  name = "${var.vm_name}"
  sources = ["source.proxmox.ubuntu-build"]

  #vm cleanup
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "echo '${var.vm_password}' | sudo -S whoami",
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

  #proxmox config upload
  provisioner "file" {
    source = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  #proxmox config distribution
  provisioner "shell" {
    inline = [
      "echo '${var.vm_password}' | sudo -S whoami",
      "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"
    ]
  }
}