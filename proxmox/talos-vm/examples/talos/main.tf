locals {
  proxmox_server_ip = "192.168.10.250"

  gateaway_address = "192.168.10.1"
  nameservers      = ["192.168.10.100", "192.168.10.200"]
  search_domain    = "example.com"

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
  source = "../.."

  vm_id   = 100
  vm_name = "talos-linux-vm"

  vm_ip_address      = "192.168.10.1"
  vm_nameservers     = local.nameservers
  vm_search_domain   = local.search_domain
  vm_gateway_address = local.gateaway_address

  tags = local.tags
}
