resource "proxmox_virtual_environment_vm" "this" {
  vm_id = var.vm_id

  name = var.vm_name

  node_name = var.pve_node

  agent {
    enabled = true
  }

  description = var.description
  tags        = var.tags

  on_boot         = var.on_boot
  stop_on_destroy = true

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.vm_store_id
    file_id      = "local:iso/${var.vm_image_name}"
    interface    = "virtio0"
    file_format  = "raw"
    size         = var.disk_size
  }

  initialization {
    datastore_id = var.vm_store_id
    ip_config {
      ipv4 {
        address = "${var.vm_ip_address}/24"
        gateway = var.vm_gateway_address
      }
      ipv6 {
        address = "dhcp"
      }
    }

    dns {
      domain  = var.vm_search_domain
      servers = length(var.vm_nameservers) == 0 ? ["8.8.8.8", "1.1.1.1"] : var.vm_nameservers
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }
}
