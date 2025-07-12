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
    data = templatefile("./data/cloud_init.yaml.tftpl", {
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
  tags            = var.tags
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

  lifecycle {
    ignore_changes = [
      cpu[0].cores,
      disk[0].size,
      network_device[0].bridge,
      initialization[0].user_data_file_id,
    ]
  }
}

resource "null_resource" "this" {
  count = !var.use_cloud_init_file ? 1 : 0

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
      "sudo ./install_guest_agent.sh"
    ]
  }

  depends_on = [
    proxmox_virtual_environment_vm.this
  ]
}
