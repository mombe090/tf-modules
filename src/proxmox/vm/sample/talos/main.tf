locals {
  proxmox_server_ip = "192.168.10.253" # Replace with your Proxmox server IP

  gateaway_address = "192.168.10.1"
  nameservers      = [] # Replace with your DNS servers
  search_domain    = "" # Replace with your search domain

  tags = ["talos-linux", "kubernetes"]

  nodes = {
    "node-1" = {
      id   = 11111
      name = "test-cp-1"
      ip   = "192.168.10.247"
      role = "controlplane",
      tags = ["controlplane", "talos", "kubernetes"]
    }
    "node-2" = {
      id   = 11112
      name = "test-worker-1"
      ip   = "192.168.10.248"
      role = "worker",
      tags = ["worker", "talos", "kubernetes"]
    }
  }
}

provider "proxmox" {
  endpoint = "https://${local.proxmox_server_ip}:8006/"

  insecure = true

  ssh {
    agent = true
  }
}

module "proxmox_vm" {
  for_each = local.nodes

  source = "../.."

  vm_id   = each.value.id
  vm_name = each.value.name

  vm_ip_address      = each.value.ip
  vm_nameservers     = local.nameservers
  vm_search_domain   = local.search_domain
  vm_gateway_address = local.gateaway_address

  tags = local.tags
}
