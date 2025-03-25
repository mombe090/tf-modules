data "tls_public_key" "this" {
  private_key_openssh = file(var.private_key_path)
}

provider "proxmox" {
  endpoint = "https://${var.pve_ip}:${var.pve_port}/"

  insecure = true

  ssh {
    agent = true
  }
}

resource "proxmox_virtual_environment_container" "ubuntu_container" {
  description = var.description

  node_name = var.pve_node
  vm_id     = var.id

  cpu {
    cores        = var.cores
    architecture = var.cpu_architecture
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.data_store
    size         = var.disk_size
  }

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = "${var.ip_address}/24"
        gateway = var.gateway_address
      }
      ipv6 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        data.tls_public_key.this.public_key_openssh
      ]
      password = var.password
    }

    dns {
      domain  = var.search_domain
      servers = length(var.nameservers) == 0 ? ["8.8.8.8", "1.1.1.1"] : var.nameservers
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = var.download_image ? proxmox_virtual_environment_download_file.this[0].id : "local:vztmpl/${element(split("/", var.image_url), length(split("/", var.image_url)) - 1)}"
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    #template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    type = var.distribution_type
  }
}

resource "proxmox_virtual_environment_download_file" "this" {
  count = var.download_image ? 1 : 0

  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.pve_node
  url          = var.image_url
}
