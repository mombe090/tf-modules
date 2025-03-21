variables {
  proxmox_server_ip = "192.168.10.253"
  control_plane_ip  = "192.168.10.11"
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_server_ip}:8006/"

  insecure = true

  ssh {
    agent = true
  }
}

run "create_proxmox_to_host_talos_control_plane" {

  variables {
    vm_id   = 99999
    vm_name = "talos-linux-vm"

    vm_ip_address      = var.control_plane_ip
    vm_nameservers     = []
    vm_search_domain   = ""
    vm_gateway_address = "192.168.10.1"

    tags = ["talos", "linux", "kubernetes"]
  }

  module {
    source = "../proxmox/vm"
  }
}

run "check_talos_cluster_is_created" {
//base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  variables {
    cluster_name              = "test-cluster"
    control_plane_ip          = var.control_plane_ip
    proxmox_server_ip_adresse = var.proxmox_server_ip
    nodes = {
      "node-1" = {
        ip   = var.control_plane_ip
        role = "controlplane"
      }
    }


  }

  assert {
    condition     = data.talos_machine_configuration.this["node-1"].cluster_endpoint == "https://${var.control_plane_ip}:6443"
    error_message = "The cluster endpoint is not correct"
  }

  assert {
    condition     = talos_cluster_kubeconfig.this.kubeconfig_raw != ""
    error_message = "Cluster did not create kubeconfig"
  }

}

run "loader" {
  variables {
    kube_url = "https://${var.control_plane_ip}:6443/livez?status=200"
    kube_ca = "" #TODO
  }

  module {
    source = "./tests/loader/kubernetes"
  }

  assert {
    condition     = data.http.validation.status_code == 401
    error_message = "Cluster did not create kubeconfig"
  }
}
