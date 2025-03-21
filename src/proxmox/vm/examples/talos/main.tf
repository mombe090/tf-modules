locals {
  proxmox_server_ip = "192.168.10.253" # Replace with your Proxmox server IP

  gateaway_address = "192.168.10.1"
  nameservers      = ["8.8.8.8", "1.1.1.1"] # Replace with your DNS servers
  search_domain    = ""                     # Replace with your search domain

  tags = ["talos-linux", "kubernetes"]
}

provider "proxmox" {
  endpoint = "https://${local.proxmox_server_ip}:8006/"

  insecure = true

  ssh {
    agent = true
  }
}

module "proxmox_vm" {
  count = 3

  source = "../.."

  vm_id   = 100 + count.index
  vm_name = "talos-linux-vm-${count.index}"

  vm_ip_address      = "192.168.10.1${count.index + 1}"
  vm_nameservers     = local.nameservers
  vm_search_domain   = local.search_domain
  vm_gateway_address = local.gateaway_address

  tags = local.tags
}
