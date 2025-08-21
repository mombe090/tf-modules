# Local values for consistent tag handling
locals {
  sorted_tags = sort(distinct(var.tags))
}

################################################################################################################################
#  Download VM Image from URL to Proxmox Datastore                                                                             #
#  url: https://search.opentofu.org/provider/bpg/proxmox/latest/docs/resources/virtual_environment_download_file#example-usage #
################################################################################################################################
resource "proxmox_virtual_environment_download_file" "this" {
  count = var.cloud_image_url != null ? 1 : 0

  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.pve_node
  url          = var.cloud_image_url
  file_name    = basename(var.cloud_image_url)
}

resource "proxmox_virtual_environment_file" "cloud_init_file" {
  count = var.use_cloud_init_file && !var.use_user_account ? 1 : 0

  content_type = "snippets"
  datastore_id = var.snippet_datastore_id
  node_name    = var.pve_node

  source_raw {
    data = templatefile("${path.module}/data/cloud_init.yaml.tftpl", {
      timezone                    = var.timezone
      username                    = var.user_config.username
      hostname                    = var.name
      fully_qualified_domain_name = "${var.name}.${var.domain}"
      root_password               = var.user_config.root_password
      user_password               = var.user_config.user_password
      ssh_public_keys             = var.user_config.ssh_public_keys
    })

    file_name = "${replace(var.name, "-", "_")}_cloud_init.yaml"
  }
}

#######################################################################################################################
# BGP-PROXMOX Provider VM RESOURCE                                                                                    #
# url: https://search.opentofu.org/provider/bpg/proxmox/latest/docs/resources/virtual_environment_vm#example-usage    #
#######################################################################################################################
resource "proxmox_virtual_environment_vm" "this" {
  vm_id     = var.id
  name      = var.name
  node_name = var.pve_node
  agent { enabled = true }
  description     = var.description
  tags            = local.sorted_tags
  on_boot         = var.on_boot
  stop_on_destroy = true
  protection      = var.protection
  cpu {
    cores = var.cores
    type  = var.cpu_type
  }
  bios    = var.bios
  machine = var.machine_type
  memory { dedicated = var.memory }
  disk {
    datastore_id = var.datastore_id
    file_id      = var.cloud_image_url != null ? proxmox_virtual_environment_download_file.this[0].id : "${var.iso_datastore_id}:iso/${var.cloud_image_name}"
    interface    = "virtio0"
    file_format  = "raw"
    size         = var.disk_size
  }
  dynamic "efi_disk" {
    for_each = var.enable_efi_disk ? [1] : []
    content {
      datastore_id = var.datastore_id
      type         = var.efi_disk_type
    }
  }
  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = "${var.ip_address}/24"
        gateway = var.gateway_address
      }
      ipv6 {
        address = "dhcp"
      }
    }
    dns {
      domain  = var.search_domain
      servers = length(var.nameservers) == 0 ? ["8.8.8.8", "1.1.1.1"] : var.nameservers
    }
    user_data_file_id = var.use_cloud_init_file ? proxmox_virtual_environment_file.cloud_init_file[0].id : null
    dynamic "user_account" {
      for_each = var.use_user_account && !var.use_cloud_init_file ? [1] : []
      content {
        username = var.user_config.username
        password = var.user_config.user_password
        keys     = var.user_config.ssh_public_keys
      }
    }
  }
  network_device { bridge = "vmbr0" }
  operating_system {
    type = var.operating_system
  }

  connection {
    type        = "ssh"
    host        = var.ip_address
    user        = var.user_config.username
    private_key = file(var.ssh_private_key_path)
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/data/install_guest_agent.sh"
    destination = "install_guest_agent.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x install_guest_agent.sh",
      "sudo ./install_guest_agent.sh ${var.get_github_keys ? var.user_config.username : ""}"
    ]
  }

  lifecycle {
    ignore_changes = [
      # Sensitive user account changes to prevent forced replacement
      initialization[0].user_account[0].keys,
      initialization[0].user_account[0].password,
      initialization[0].interface,
      initialization[0].datastore_id,
      disk,
      # If you want to ignore DNS server changes (optional):
      initialization[0].dns[0].servers,
      # If you want to ignore tags changes (optional):
      tags,
    ]
  }
}
