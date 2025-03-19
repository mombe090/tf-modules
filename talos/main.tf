resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
        }
      }
    }
  )
}

resource "null_resource" "this" {
  connection {
    type        = "ssh"
    host        = var.proxmox_server_ip_adresse
    user        = var.proxmox_user
    private_key = file(var.proxmox_user_ssh_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/scripts/download-talos.sh"
    destination = "download-talos.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x download-talos.sh",
      "./download-talos.sh ${data.talos_image_factory_urls.this.urls["disk_image"]} ${var.refresh_talos_image_in_proxmox}",
    ]
  }

  triggers = {
    refresh_talos_image = var.refresh_talos_image_in_proxmox
  }
}

# voir https://search.opentofu.org/provider/siderolabs/talos/latest/docs/resources/cluster_kubeconfig
resource "talos_machine_secrets" "this" {}

# Application de la configuration sur le control plane
resource "talos_machine_configuration_apply" "this" {
  for_each = var.nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.value.ip
  config_patches              = var.talos_config_patches
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.this]
  node                 = [for k, v in var.nodes : v.ip if v.role == "controlplane"][0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  node                 = [for k, v in var.nodes : v.ip if v.role == "controlplane"][0]
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    read = "1m"
  }
}
