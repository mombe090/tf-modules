output "vm_module" {
  value       = module.proxmox_vm.outputs[*]
  description = "Outputs of the proxmox_virtual_environment_vm resource"
}
