terraform {
  required_version = ">= 1.9.0"
}

module "talos" {
  source                    = "../"
  cluster_name              = "cluster-sample-1"
  control_plane_ip          = "192.168.10.11"
  proxmox_server_ip_adresse = "192.168.10.253"
  talos_config_patches = [
    yamlencode({
      machine = {
        kubelet = {
          extraMounts = [
            {
              destination = "/var/lib/longhorn",
              type        = "bind",
              source      = "/var/lib/longhorn",
              options     = ["bind", "rshared", "rw"]
            }
          ]
        }

        registries = {
          mirrors = {
            "docker.io" = {
              endpoints = ["https://mirror.gcr.io"]
            }
          }
        }
      }

      cluster = {
        proxy = {
          image     = "registry.k8s.io/kube-proxy:v1.32.0"
          extraArgs = { nodeport-addresses = "0.0.0.0/0" }
        }
      }
    })
  ]
  nodes = {
    "node-1" = {
      ip   = "192.168.10.11"
      role = "controlplane"
    },
    "node-2" = {
      ip   = "192.168.10.12"
      role = "controlplane"
    }
    "node-3" = {
      ip   = "192.168.10.13"
      role = "worker"
    }
  }
}
