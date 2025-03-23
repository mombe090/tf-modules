variable "talos_image_version" {
  type        = string
  description = "Talos image version"
  default     = "v1.9.4"
}

variable "refresh_talos_image_in_proxmox" {
  type        = bool                                                                                          # true or false
  description = "Refresh Talos image in Proxmox (By default false, no need to download the image every time)" # true or false
  default     = true
}

######################################################################################
# Talos tools extensions                                                             #
# https://factory.talos.dev/?arch=amd64&platform=nocloud&target=cloud&version=1.9.5. #
######################################################################################
variable "talos_tools_extensions" {
  type        = list(string)
  description = "Talos tools extensions"
  default = [
    "qemu-guest-agent",
    "iscsi-tools",
    "util-linux-tools"
  ]
}

variable "cluster_name" {
  type        = string
  description = "Name of the Talos cluster"
}

variable "nodes" {
  type = map(object({
    ip      = string
    role    = string
    patches = list(string)
  }))
  description = "Nodes of the Talos cluster with their IP, role and patches"
}

variable "control_plane_ip" {
  type        = string
  description = "Name of the control plane IP"
}

variable "proxmox_server_ip_adresse" {
  type        = string
  description = "Proxmox server IP adresse"
}

variable "proxmox_server_port" {
  type        = number
  description = "Proxmox server port"
  default     = 8006
}

variable "proxmox_user" {
  type        = string
  description = "User for Proxmox server with admin rights"
  default     = "root"
}

variable "proxmox_user_ssh_key_path" {
  type        = string
  description = "Path to the SSH key for the Proxmox user"
  default     = "~/.ssh/id_ed25519"
}
