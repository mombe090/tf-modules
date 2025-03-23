###################################################
# Talos Image Factory Stable Version              #
###################################################
data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = true
  }
}

##################################################################################################################################
# Talos Image Factory extensions                                                                                                 #
# see https://factory.talos.dev/?arch=amd64&board=undefined&platform=nocloud&secureboot=undefined&target=cloud&version=1.9.5     #
##################################################################################################################################
data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_image_version
  filters = {
    names = var.talos_tools_extensions
  }
}

####################################################
# Talos Image Factory Schematic                    #
####################################################
data "talos_image_factory_urls" "this" {
  talos_version = var.talos_image_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "nocloud"
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for k, v in var.nodes : v.ip]
  endpoints            = [for k, v in var.nodes : v.ip if v.role == "controlplane"]
}

#Configuration du control plane
data "talos_machine_configuration" "this" {
  for_each = var.nodes

  cluster_name     = var.cluster_name
  machine_type     = each.value.role
  cluster_endpoint = "https://${var.control_plane_ip}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

#Get cluster health before releasing terraform apply
data "talos_cluster_health" "this" {
  depends_on = [
    talos_machine_configuration_apply.this,
    talos_machine_bootstrap.this
  ]
  client_configuration = data.talos_client_configuration.this.client_configuration
  control_plane_nodes  = [var.control_plane_ip]
  worker_nodes         = [for k, v in var.nodes : v.ip if v.role == "controlplane"]
  endpoints            = data.talos_client_configuration.this.endpoints
  timeouts = {
    read = "8m"
  }
}
