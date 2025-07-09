variable "vm_id" {
  type        = number
  description = "Id of the Virtual Machine"
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "vm_datastore_id" {
  type        = string
  description = "Storage ID of the VM"
  default     = "local-lvm"
}

variable "vm_image_name" {
  type        = string
  description = "Name of the image to use, must be /var/lib/vz/template/iso/"
}

variable "iso_datastore_id" {
  type        = string
  description = "Storage ID of the ISO"
  default     = "local"
}

variable "cloud_init_file_id" {
  type        = string
  description = "Storage ID of the cloud-init file"
  default     = null
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
  default     = 4
}

variable "cpu_type" {
  type        = string
  description = "CPU type for this VM"
  default     = "x86-64-v2-AES"
}

variable "memory" {
  type        = number
  description = "Amount of memory for this VM"
  default     = 4096
}

variable "bios" {
  type        = string
  description = "BIOS type for this VM"
  default     = "ovmf"
}

variable "machine_type" {
  type        = string
  description = "Machine type for this VM"
  default     = "q35"
}

variable "operating_system" {
  type        = string
  description = "Operating system for this VM"
  default     = "l26" #Windows win11
}

variable "disk_size" {
  type        = number
  description = "Disk size for this VM"
  default     = 20
}

variable "efi_disk_type" {
  type        = string
  description = "EFI disk type for this LxC Container"
  default     = "4m"
}

variable "enable_efi_disk" {
  type        = bool
  description = "Enable EFI disk for this LxC Container"
  default     = true
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

variable "protection" {
  type        = bool
  description = "Enable protection for this VM"
  default     = false
}

variable "enable_user_account" {
  type        = bool
  description = "Enable user account for this VM"
  default     = false
}

variable "user_account" {
  description = "User account for this VM"

  type = map(object({
    username = string
    password = optional(string, null)
    keys     = optional(list(string), [])
  }))


  sensitive = true
  default   = null
}
