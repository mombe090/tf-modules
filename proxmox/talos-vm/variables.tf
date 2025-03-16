variable "vm_id" {
  type        = number
  description = "Id of the Virtual Machine"
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "vm_store_id" {
  type        = string
  description = "Storage ID of the VM"
  default     = "local-lvm"
}

variable "vm_image_name" {
  type        = string
  description = "Name of the image to use, must be /var/lib/vz/template/iso/"
  default     = "talos-nocloud-amd64-qemu-agent.img"
}

variable "vm_ip_address" {
  type        = string
  description = "IP address of the VM"
}

variable "vm_gateway_address" {
  type        = string
  description = "Gateway IP address of the VM"
}

variable "vm_nameservers" {
  type        = list(string)
  description = "Nameserver IP addresses of the VM"
}
variable "vm_search_domain" {
  type        = string
  description = "Search domain of the VM"
}

variable "on_boot" {
  type        = bool
  description = "Start VM on boot"
  default     = true
}

variable "pve_node" {
  type        = string
  description = "Proxmox node name"
  default     = "pve"
}

variable "cores" {
  type        = number
  description = "Number of CPU cores for this VM"
  default     = 2
}

variable "memory" {
  type        = number
  description = "Amount of memory for this VM"
  default     = 2048
}

variable "disk_size" {
  type        = number
  description = "Disk size for this VM"
  default     = 20
}

variable "description" {
  type        = string
  description = "Description of the VM"
  default     = "Managed by OpenTofu"
}

variable "tags" {
  type        = list(string)
  description = "Resource tags"
}
