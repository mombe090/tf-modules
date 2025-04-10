terraform {
  required_version = ">= 1.9.0"
}

module "talos" {
  source                    = "../../src/talos"
  cluster_name              = "cluster-sample-1"
  control_plane_ip          = "192.168.10.247"
  proxmox_server_ip_adresse = "192.168.10.253"
  nodes = {
    "node-1" = {
      ip      = "192.168.10.247"
      role    = "controlplane",
      patches = [templatefile("${path.module}/templates/patches.yaml.tftpl", { "role" : "controlplane" })]
    },
    "node-2" = {
      ip      = "192.168.10.248"
      role    = "worker",
      patches = [templatefile("${path.module}/templates/patches.yaml.tftpl", { "role" : "worker" })]
    }
  }
}
