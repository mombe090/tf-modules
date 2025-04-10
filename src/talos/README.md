<!-- BEGIN_TF_DOCS -->
# This Module is used to create a Talos Kubernetes Cluster
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.3 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.73.1 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.7.1 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.7.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Talos cluster | `string` | n/a | yes |
| <a name="input_control_plane_ip"></a> [control\_plane\_ip](#input\_control\_plane\_ip) | Name of the control plane IP | `string` | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Nodes of the Talos cluster with their IP, role and patches | <pre>map(object({<br/>    ip      = string<br/>    role    = string<br/>    patches = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_proxmox_server_ip_adresse"></a> [proxmox\_server\_ip\_adresse](#input\_proxmox\_server\_ip\_adresse) | Proxmox server IP adresse | `string` | n/a | yes |
| <a name="input_proxmox_server_port"></a> [proxmox\_server\_port](#input\_proxmox\_server\_port) | Proxmox server port | `number` | `8006` | no |
| <a name="input_proxmox_user"></a> [proxmox\_user](#input\_proxmox\_user) | User for Proxmox server with admin rights | `string` | `"root"` | no |
| <a name="input_proxmox_user_ssh_key_path"></a> [proxmox\_user\_ssh\_key\_path](#input\_proxmox\_user\_ssh\_key\_path) | Path to the SSH key for the Proxmox user | `string` | `"~/.ssh/id_ed25519"` | no |
| <a name="input_refresh_talos_image_in_proxmox"></a> [refresh\_talos\_image\_in\_proxmox](#input\_refresh\_talos\_image\_in\_proxmox) | Refresh Talos image in Proxmox (By default false, no need to download the image every time) | `bool` | `true` | no |
| <a name="input_talos_image_version"></a> [talos\_image\_version](#input\_talos\_image\_version) | Talos image version | `string` | `"v1.9.5"` | no |
| <a name="input_talos_tools_extensions"></a> [talos\_tools\_extensions](#input\_talos\_tools\_extensions) | Talos tools extensions. example: https://factory.talos.dev/?arch=amd64&platform=nocloud&target=cloud&version=1.9.5 | `list(string)` | <pre>[<br/>  "qemu-guest-agent",<br/>  "iscsi-tools",<br/>  "util-linux-tools"<br/>]</pre> | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_health_check"></a> [health\_check](#output\_health\_check) | Talos health check output |
| <a name="output_k8s_config"></a> [k8s\_config](#output\_k8s\_config) | Kubernetes client configuration containing the kubeconfig |
| <a name="output_latest_talos_stable_version"></a> [latest\_talos\_stable\_version](#output\_latest\_talos\_stable\_version) | Get the latest Talos stable version |
| <a name="output_talos_client_config"></a> [talos\_client\_config](#output\_talos\_client\_config) | Talos client configuration containing the talosconfig |
| <a name="output_talos_installer_image_url"></a> [talos\_installer\_image\_url](#output\_talos\_installer\_image\_url) | Get the latest Talos installer image url for raw xz compressed image |

## Modules

No modules.
## Resources

| Name | Type |
|------|------|
| [null_resource.this](https://registry.terraform.io/providers/hashicorp/null/3.2.3/docs/resources/resource) | resource |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/resources/cluster_kubeconfig) | resource |
| [talos_image_factory_schematic.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/resources/image_factory_schematic) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/resources/machine_secrets) | resource |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/data-sources/client_configuration) | data source |
| [talos_cluster_health.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/data-sources/cluster_health) | data source |
| [talos_image_factory_extensions_versions.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_image_factory_urls.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/data-sources/image_factory_urls) | data source |
| [talos_image_factory_versions.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/data-sources/image_factory_versions) | data source |
| [talos_machine_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.1/docs/data-sources/machine_configuration) | data source |

# Exemples :

## Kubernetes Cluster Creation with Talos :
```hcl
terraform {
  required_version = ">= 1.9.0"
}

module "talos" {
  source                    = "../"
  cluster_name              = "cluster-sample-1"
  control_plane_ip          = "192.168.10.11"
  proxmox_server_ip_adresse = "192.168.10.253"
  talos_config_patches = [
    yamlencode({
      machine = {
        kubelet = {
          extraMounts = [
            {
              destination = "/var/lib/longhorn",
              type        = "bind",
              source      = "/var/lib/longhorn",
              options     = ["bind", "rshared", "rw"]
            }
          ]
        }

        registries = {
          mirrors = {
            "docker.io" = {
              endpoints = ["https://mirror.gcr.io"]
            }
          }
        }
      }

      cluster = {
        proxy = {
          image     = "registry.k8s.io/kube-proxy:v1.32.0"
          extraArgs = { nodeport-addresses = "0.0.0.0/0" }
        }
      }
    })
  ]
  nodes = {
    "node-1" = {
      ip   = "192.168.10.11"
      role = "controlplane"
    },
    "node-2" = {
      ip   = "192.168.10.12"
      role = "controlplane"
    }
    "node-3" = {
      ip   = "192.168.10.13"
      role = "worker"
    }
  }
}

```
<!-- END_TF_DOCS -->
