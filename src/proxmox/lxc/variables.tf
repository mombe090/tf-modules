variable "hostname" {
  type        = string
  description = "Name of the LxC container"
}

variable "description" {
  type        = string
  description = "Description of the LxC container"
  default     = ""
}

variable "id" {
  type        = number
  description = "ID of the LxC container"
}

variable "cores" {
  type        = number
  description = "Number of CPU cores for this LxC Container"
  default     = 1
}

variable "cpu_architecture" {
  type        = string
  description = "Cpu architecture for this LxC Container"
  default     = "amd64"
}

variable "memory" {
  type        = number
  description = "Amount of memory for this LxC Container"
  default     = 2048
}

variable "disk_size" {
  type        = number
  description = "Disk size for this LxC Container"
  default     = 10
}

variable "ip_address" {
  type        = string
  description = "IP address of the LxC Container"
}

variable "gateway_address" {
  type        = string
  description = "Gateway IP address of the LxC Container"
  default     = "192.168.10.1"
}

variable "nameservers" {
  type        = list(string)
  description = "Nameserver IP addresses of the LxC Container"
  default     = []
}
variable "search_domain" {
  type        = string
  description = "Search domain of the LxC Container"
  default     = ""
}

variable "pve_node" {
  type        = string
  description = "Proxmox node name"
  default     = "pve"
}

variable "pve_ip" {
  type        = string
  description = "Proxmox node ip address"
  default     = "192.168.10.253"
}

variable "pve_port" {
  type        = number
  description = "Proxmox node ip port"
  default     = 8006
}

variable "image_url" {
  type        = string
  description = "URL for this LxC Container"
  default     = "http://download.proxmox.com/images/system/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
}

variable "data_store" {
  type        = string
  description = "Proxmox data store name"
  default     = "local-lvm"
}

variable "distribution_type" {
  type        = string
  description = "Distribution type for this LxC Container"
  default     = "ubuntu"
}

variable "private_key_path" {
  type        = string
  description = "Allowed key for this LxC Container"
  default     = "~/.ssh/id_ed25519"
}

variable "password" {
  type        = string
  description = "Password for this LxC Container"
  sensitive   = true
}

variable "download_image" {
  type        = bool
  description = "Download image for this LxC Container"
  default     = true
}
