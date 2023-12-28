#common variables
variable "ssh_username" {
  type = string
}

variable "iso_file" {
  type = string
}

variable "proxmox_api_address" {
  type = string
}

variable "provisioning_server_address" {
  type = string
}

variable "provisioning_server_port_range_min" {
  type = number
}

variable "provisioning_server_port_range_max" {
  type = number
}


#template specific variables
variable "vm_id" {
  type = number
}

variable "vm_name" {
  type = string
}

variable "vm_description" {
  type = string
}

variable "vm_cores" {
  type = number
}

variable "vm_memory" {
  type = number
}

variable "ssh_timeout" {
  type = string
}

variable "disk_size" {
  type = string
}

variable "provisioning" {
  type = list(string)
}


#secrets
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
