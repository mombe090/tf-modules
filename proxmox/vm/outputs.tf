output "vm_id" {
  value       = proxmox_virtual_environment_vm.this.id
  description = "ID of the VM"
}

output "agent" {
  value       = proxmox_virtual_environment_vm.this.agent[0].enabled
  description = "Agent enabled"
}

output "vm_cpu_count" {
  value       = proxmox_virtual_environment_vm.this.cpu[0].cores
  description = "Number of CPU cores"
}

output "vm_memory" {
  value       = proxmox_virtual_environment_vm.this.memory[0].dedicated
  description = "Amount of memory allocated to the VM"
}

output "vm_disk_size" {
  value       = "${proxmox_virtual_environment_vm.this.disk[0].size} Go"
  description = "Size of the VM disk"
}

output "network_config" {
  value = {
    ip_address     = proxmox_virtual_environment_vm.this.initialization[0].ip_config[0].ipv4[0].address
    gateway        = proxmox_virtual_environment_vm.this.initialization[0].ip_config[0].ipv4[0].gateway
    search_domains = proxmox_virtual_environment_vm.this.initialization[0].dns[0].domain
    servers        = proxmox_virtual_environment_vm.this.initialization[0].dns[0].servers
  }
  description = "Network configuration of the VM"
}
