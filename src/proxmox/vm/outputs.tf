output "vm_id" {
  value       = try(proxmox_virtual_environment_vm.this[0].id, null)
  description = "ID of the VM"
}

output "vm_name" {
  value       = try(proxmox_virtual_environment_vm.this[0].name, null)
  description = "Name of the VM"
}

output "agent" {
  value       = try(proxmox_virtual_environment_vm.this[0].agent[0].enabled, null)
  description = "Agent enabled"
}

output "vm_cpu_count" {
  value       = try(proxmox_virtual_environment_vm.this[0].cpu[0].cores, null)
  description = "Number of CPU cores"
}

output "vm_memory" {
  value       = try(proxmox_virtual_environment_vm.this[0].memory[0].dedicated, null)
  description = "Amount of memory allocated to the VM"
}

output "vm_disk_size" {
  value       = try("${proxmox_virtual_environment_vm.this[0].disk[0].size} Go", null)
  description = "Size of the VM disk"
}

output "network_config" {
  value = {
    ip_address     = try(proxmox_virtual_environment_vm.this[0].initialization[0].ip_config[0].ipv4[0].address, null)
    gateway        = try(proxmox_virtual_environment_vm.this[0].initialization[0].ip_config[0].ipv4[0].gateway, null)
    search_domains = try(proxmox_virtual_environment_vm.this[0].initialization[0].dns[0].domain, null)
    servers        = try(proxmox_virtual_environment_vm.this[0].initialization[0].dns[0].servers, null)
  }
  description = "Network configuration of the VM"
}
