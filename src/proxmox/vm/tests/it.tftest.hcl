#########################################################
# Global Variables to be used in all part of this Test  #
#########################################################
variables {
  proxmox_server_ip = "192.168.10.253"
}

#########################################################
# Provider Configuration use to connect to PVE          #
#########################################################
provider "proxmox" {
  endpoint = "https://${var.proxmox_server_ip}:8006/"

  insecure = true

  ssh {
    agent = true
  }
}

# Setup module execution to create the random values
run "random" {
  module {
    source = "./tests/setup"
  }
}

#########################################################
# Create a VM in Proxmox with BGP provider              #
#########################################################
run "create_proxmox_to_host_talos_control_plane" {

  # local variables to be used in this test
  variables {
    vm_id   = run.random.integer
    vm_name = run.random.pet

    vm_ip_address      = "192.168.10.${run.random.integer}"
    vm_nameservers     = []
    vm_search_domain   = ""
    vm_gateway_address = "192.168.10.1"

    tags = ["talos", "linux", "kubernetes"]
  }

  # Checking if the VM was created with the passed id
  assert {
    condition    = proxmox_virtual_environment_vm.this.id == tostring(run.random.integer)
    error_message = "VM ID is not equal to the last digit of the IP address"
  }

  # Checking if the VM was created with the passed id
  assert {
    condition    = proxmox_virtual_environment_vm.this.name == run.random.pet
    error_message = "VM ID is not equal to the generated pet name"
  }
}
