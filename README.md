# tf-modules
Dépôt pour quelques modules terraform et openTofu
Any arbitrary text can be placed anywhere in the content



and even in between sections. also spaces will be preserved:

- item 1
  - item 1-1
  - item 1-2
- item 2
- item 3

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | >= 0.68.1 |

and they don't even need to be in the default order

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_outputs"></a> [outputs](#output\_outputs) | Outputs of the proxmox\_virtual\_environment\_vm resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cores"></a> [cores](#input\_cores) | Number of CPU cores for this VM | `number` | `2` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the VM | `string` | `"Managed by OpenTofu"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for this VM | `number` | `20` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of memory for this VM | `number` | `2048` | no |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Network configuration for the VM, must be a map with gateway, domain, and nameservers | <pre>object({<br/>    gateway : string<br/>    domain : string<br/>    nameservers : list(string)<br/>  })</pre> | n/a | yes |
| <a name="input_on_boot"></a> [on\_boot](#input\_on\_boot) | Start VM on boot | `bool` | `true` | no |
| <a name="input_pve_node"></a> [pve\_node](#input\_pve\_node) | Proxmox node name | `string` | `"pve"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `list(string)` | n/a | yes |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | Id of the Virtual Machine | `number` | n/a | yes |
| <a name="input_vm_image_name"></a> [vm\_image\_name](#input\_vm\_image\_name) | Name of the image to use, must be /var/lib/vz/template/iso/ | `string` | `"talos-nocloud-amd64-qemu-agent.img"` | no |
| <a name="input_vm_ip_address"></a> [vm\_ip\_address](#input\_vm\_ip\_address) | IP address of the VM | `string` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Name of the virtual machine | `string` | n/a | yes |
| <a name="input_vm_store_id"></a> [vm\_store\_id](#input\_vm\_store\_id) | Storage ID of the VM | `string` | `"local-lvm"` | no |
