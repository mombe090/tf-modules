# VM Identity
variable "id" {
  type        = number
  description = "Id of the Virtual Machine"
}

variable "name" {
  type        = string
  description = "Name of the virtual machine"
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


# VM Storage and Image Configuration
variable "datastore_id" {
  type        = string
  description = "Storage ID of the VM"
  default     = "local-lvm"
}

variable "disk_size" {
  type        = number
  description = "Disk size for this VM"
  default     = 20
}

variable "enable_efi_disk" {
  type        = bool
  description = "Enable EFI disk for this LxC Container"
  default     = true
}

variable "efi_disk_type" {
  type        = string
  description = "EFI disk type for this LxC Container"
  default     = "4m"
}

variable "iso_datastore_id" {
  type        = string
  description = "Storage ID of the ISO"
  default     = "local"
}

variable "snippet_datastore_id" {
  type        = string
  description = "Storage ID of the snippets"
  default     = "local"
}


# VM Cloud Image Configuration
variable "cloud_image_url" {
  type        = string
  description = "URL of the image Download from the internet"
  default     = null
}

variable "cloud_image_name" {
  type        = string
  description = "Name of the image to use, must be /var/lib/vz/template/iso/"
  default     = null
}

# VM Network Configuration
variable "domain" {
  description = "Domain for the Virtual Machine"
  type        = string
  default     = "example.com"
}

variable "gateway_address" {
  type        = string
  description = "Gateway IP address of the VM"
  default     = "192.168.10.1"
}

variable "ip_address" {
  type        = string
  description = "IP address of the VM"
}

variable "nameservers" {
  type        = list(string)
  description = "Nameserver IP addresses of the VM"
}

variable "search_domain" {
  type        = string
  description = "Search domain of the VM"
}


# Operating System and Linux Configuration
variable "protection" {
  type        = bool
  description = "Enable protection for this VM"
  default     = false
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

variable "timezone" {
  description = "Timezone for the Virtual Machine"
  type        = string
  default     = "America/Toronto"
}


# User Configuration
variable "ssh_private_key_path" {
  type        = string
  description = "Path to the private key for the VM"
  default     = "~/.ssh/id_ed25519"
}

variable "use_cloud_init_file" {
  type        = bool
  description = "Use cloud-init file for this VM"
  default     = false
}

variable "use_user_account" {
  type        = bool
  description = "Use user account for this VM"
  default     = false

  validation {
    condition     = !var.use_cloud_init_file || !var.use_user_account
    error_message = "When use_cloud_init_file is true, use_user_account must be false."
  }
}

variable "user_config" {
  type = object({
    username        = string
    root_password   = optional(string, null)
    user_password   = optional(string, null)
    ssh_public_keys = optional(list(string), [])
  })
  description = "Cloud-init configuration file content"
  sensitive   = true
  default     = null
}

variable "get_github_keys" {
  type        = bool
  description = "Get public keys from GitHub"
  default     = true

  validation {
    condition     = var.get_github_keys || length(var.user_config.ssh_public_keys) > 0
    error_message = "Either get_github_keys must be true or user_config.ssh_public_keys must not be empty."
  }
}
