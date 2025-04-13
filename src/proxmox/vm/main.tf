#######################################################################################################################
# BGP-PROXMOX Provider VM RESOURCE                                                                                    #
# url: https://search.opentofu.org/provider/bpg/proxmox/latest/docs/resources/virtual_environment_vm#example-usage    #
#######################################################################################################################
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

  protection = var.protection

  cpu {
    cores = var.cores
    type  = var.cpu_type
  }

  bios    = var.bios
  machine = var.machine_type

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = var.iso_datastore_id == "local" ? "${var.iso_datastore_id}:iso/${var.vm_image_name}" : "${var.iso_datastore_id}:iso/${var.vm_image_name}"
    interface    = "virtio0"
    file_format  = "raw"
    size         = var.disk_size
  }

  dynamic "efi_disk" {
    for_each = var.enable_efi_disk ? [1] : []
    content {
      datastore_id = var.vm_datastore_id
      type         = var.efi_disk_type
    }
  }

  initialization {
    datastore_id = var.vm_datastore_id
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

    user_data_file_id = var.cloud_init_file_id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = var.operating_system
  }
}
