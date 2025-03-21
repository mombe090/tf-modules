<!-- BEGIN_TF_DOCS -->
# This Module is used to create a Virtual Machine in Proxmox
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.68.1 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.73.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `list(string)` | n/a | yes |
| <a name="input_vm_gateway_address"></a> [vm\_gateway\_address](#input\_vm\_gateway\_address) | Gateway IP address of the VM | `string` | n/a | yes |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | Id of the Virtual Machine | `number` | n/a | yes |
| <a name="input_vm_ip_address"></a> [vm\_ip\_address](#input\_vm\_ip\_address) | IP address of the VM | `string` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Name of the virtual machine | `string` | n/a | yes |
| <a name="input_vm_nameservers"></a> [vm\_nameservers](#input\_vm\_nameservers) | Nameserver IP addresses of the VM | `list(string)` | n/a | yes |
| <a name="input_vm_search_domain"></a> [vm\_search\_domain](#input\_vm\_search\_domain) | Search domain of the VM | `string` | n/a | yes |
| <a name="input_cores"></a> [cores](#input\_cores) | Number of CPU cores for this VM | `number` | `4` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the VM | `string` | `"Managed by OpenTofu"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for this VM | `number` | `20` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of memory for this VM | `number` | `4096` | no |
| <a name="input_on_boot"></a> [on\_boot](#input\_on\_boot) | Start VM on boot | `bool` | `true` | no |
| <a name="input_pve_node"></a> [pve\_node](#input\_pve\_node) | Proxmox node name | `string` | `"pve"` | no |
| <a name="input_vm_image_name"></a> [vm\_image\_name](#input\_vm\_image\_name) | Name of the image to use, must be /var/lib/vz/template/iso/ | `string` | `"talos-nocloud-amd64-qemu-agent.img"` | no |
| <a name="input_vm_store_id"></a> [vm\_store\_id](#input\_vm\_store\_id) | Storage ID of the VM | `string` | `"local-lvm"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent"></a> [agent](#output\_agent) | Agent enabled |
| <a name="output_network_config"></a> [network\_config](#output\_network\_config) | Network configuration of the VM |
| <a name="output_vm_cpu_count"></a> [vm\_cpu\_count](#output\_vm\_cpu\_count) | Number of CPU cores |
| <a name="output_vm_disk_size"></a> [vm\_disk\_size](#output\_vm\_disk\_size) | Size of the VM disk |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | ID of the VM |
| <a name="output_vm_memory"></a> [vm\_memory](#output\_vm\_memory) | Amount of memory allocated to the VM |

## Modules

No modules.
## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_vm.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |

# Exemples :

## Creation d'une machine virtuelle pour Talos :
```hcl
module "proxmox_vm" {
  source = "../.."
  network_config = {
    gateway : "192.168.10.1"
    domain : "example.com"
    nameservers : [
      "192.168.10.100",
      "192.168.10.200",
      "1.1.1.1"
    ]
  }
  tags = ["talos-linux", "kubernetes"]
  vm_id  = 100
  vm_ip_address = "192.168.10.2"
  vm_name = "test-vm"
}
```
<!-- END_TF_DOCS -->
