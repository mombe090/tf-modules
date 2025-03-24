############################################################################################################
# Getting the schematic ID from the talos image factory web site                                           #
# see: https://factory.talos.dev/                                                                          #
############################################################################################################
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

##################################################################################################################################
# This null_resource is used to download the talos image from the talos image factory to the proxmox server.                     #                                                                                                #
# BGP has a resource to download but currently the xz file is not supported.                                                     #
# Note: once the xz file is supported, this resource can be removed and replace by :                                             #
# https://search.opentofu.org/provider/bpg/proxmox/latest/docs/resources/virtual_environment_download_file                       #
# https://search.opentofu.org/provider/bpg/proxmox/latest/docs/resources/virtual_environment_file                                #
##################################################################################################################################
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

# See https://search.opentofu.org/provider/siderolabs/talos/latest/docs/resources/cluster_kubeconfig
resource "talos_machine_secrets" "this" {}

###################################################################################################################
# Configuration for each talos vm                                                                                 #
# see: https://search.opentofu.org/provider/siderolabs/talos/latest/docs/resources/machine_configuration_apply    #
###################################################################################################################
resource "talos_machine_configuration_apply" "this" {
  for_each = var.nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.value.ip
  config_patches              = each.value.patches
}

###################################################################################################################
# Bootstrap the talos kubernetes cluster                                                                          #
# see: https://search.opentofu.org/provider/siderolabs/talos/latest/docs/resources/machine_bootstrap              #
###################################################################################################################
resource "talos_machine_bootstrap" "this" {
  node                 = [for k, v in var.nodes : v.ip if v.role == "controlplane"][0]
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [talos_machine_configuration_apply.this]
}

###################################################################################################################
# Configuration to get the kubeconfig and talos configuration for the talos kubernetes cluster                    #
# see: https://search.opentofu.org/provider/siderolabs/talos/latest/docs/resources/cluster_kubeconfig             #
###################################################################################################################
resource "talos_cluster_kubeconfig" "this" {
  node                 = [for k, v in var.nodes : v.ip if v.role == "controlplane"][0]
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    read = "1m"
  }

  depends_on = [
    talos_machine_bootstrap.this,
    data.talos_cluster_health.this
  ]
}
