################################################################################################################################
#  Download VM Image from URL to Proxmox Datastore                                                                             #
#  url: https://search.opentofu.org/provider/bpg/proxmox/latest/docs/resources/virtual_environment_download_file#example-usage #
################################################################################################################################
resource "proxmox_virtual_environment_download_file" "this" {
  count = var.vm_image_url != null ? 1 : 0

  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.pve_node
  url          = var.vm_image_url
  file_name    = basename(var.vm_image_url)
}

resource "proxmox_virtual_environment_file" "cloud_init_file" {
  count = var.use_cloud_init_file ? 1 : 0

  content_type = "snippets"
  datastore_id = var.snippet_datastore_id
  node_name    = var.pve_node

  source_raw {
    data = templatefile("./data/cloud_init.yaml.tftpl", {
      timezone                    = var.vm_timezone
      username                    = var.cloud_init_config.username
      hostname                    = var.vm_name
      fully_qualified_domain_name = "${var.vm_name}.${var.vm_domain}"
      root_password               = var.cloud_init_config.root_password
      user_password               = var.cloud_init_config.user_password
      ssh_public_keys             = var.cloud_init_config.ssh_public_keys
    })

    file_name = "${replace(var.vm_name, "-", "_")}_cloud_init.yaml"
  }
}

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
    file_id      = var.vm_image_url != null ? proxmox_virtual_environment_download_file.this[0].id : "${var.iso_datastore_id}:iso/${var.vm_image_name}"
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

    user_data_file_id = var.use_cloud_init_file ? proxmox_virtual_environment_file.cloud_init_file[0].id : null

    dynamic "user_account" {
      for_each = var.enable_user_account && !var.use_cloud_init_file ? [1] : []
      content {
        username = var.user_account.username
        password = var.user_account.password
        keys     = var.user_account.keys
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }

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
    host        = var.vm_ip_address
    user        = var.user_account.username
    private_key = file(var.ssh_private_key_path)
    timeout     = "3m"
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

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    proxmox_virtual_environment_vm.this
  ]
}
