<!-- BEGIN_TF_DOCS -->
# This Module is used to create a Talos Kubernetes Cluster
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.68.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.6 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.75.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Name of the LxC container | `string` | n/a | yes |
| <a name="input_id"></a> [id](#input\_id) | ID of the LxC container | `number` | n/a | yes |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | IP address of the LxC Container | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | Password for this LxC Container | `string` | n/a | yes |
| <a name="input_cores"></a> [cores](#input\_cores) | Number of CPU cores for this LxC Container | `number` | `1` | no |
| <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture) | Cpu architecture for this LxC Container | `string` | `"amd64"` | no |
| <a name="input_data_store"></a> [data\_store](#input\_data\_store) | Proxmox data store name | `string` | `"local-lvm"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the LxC container | `string` | `""` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for this LxC Container | `number` | `10` | no |
| <a name="input_distribution_type"></a> [distribution\_type](#input\_distribution\_type) | Distribution type for this LxC Container | `string` | `"ubuntu"` | no |
| <a name="input_download_image"></a> [download\_image](#input\_download\_image) | Download image for this LxC Container | `bool` | `true` | no |
| <a name="input_gateway_address"></a> [gateway\_address](#input\_gateway\_address) | Gateway IP address of the LxC Container | `string` | `"192.168.10.1"` | no |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | URL for this LxC Container | `string` | `"http://download.proxmox.com/images/system/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of memory for this LxC Container | `number` | `2048` | no |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | Nameserver IP addresses of the LxC Container | `list(string)` | `[]` | no |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | Allowed key for this LxC Container | `string` | `"~/.ssh/id_ed25519"` | no |
| <a name="input_pve_ip"></a> [pve\_ip](#input\_pve\_ip) | Proxmox node ip address | `string` | `"192.168.10.253"` | no |
| <a name="input_pve_node"></a> [pve\_node](#input\_pve\_node) | Proxmox node name | `string` | `"pve"` | no |
| <a name="input_pve_port"></a> [pve\_port](#input\_pve\_port) | Proxmox node ip port | `number` | `8006` | no |
| <a name="input_search_domain"></a> [search\_domain](#input\_search\_domain) | Search domain of the LxC Container | `string` | `""` | no |
## Outputs

No outputs.

## Modules

No modules.
## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_container.ubuntu_container](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_container) | resource |
| [proxmox_virtual_environment_download_file.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) | resource |
| [tls_public_key.this](https://registry.terraform.io/providers/hashicorp/tls/4.0.6/docs/data-sources/public_key) | data source |

# Exemples :

## Lxc Container Creation :
```hcl
terraform {
  required_version = ">= 1.9.0"
}

module "lxc" {
  source         = "../"
  hostname       = "my-test-container"
  id             = 1234
  ip_address     = "192.168.10.123"
  password       = "test123"
  download_image = false #to true if image is not already downloaded
}

```
<!-- END_TF_DOCS -->
