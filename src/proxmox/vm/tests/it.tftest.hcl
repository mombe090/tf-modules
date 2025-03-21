variables {
  proxmox_server_ip = "192.168.10.253"
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_server_ip}:8006/"

  insecure = true

  ssh {
    agent = true
  }
}

run "random" {
  module {
    source = "./tests/setup"
  }
}

run "create_proxmox_to_host_talos_control_plane" {

  variables {
    vm_id   = run.random.integer
    vm_name = run.random.pet

    vm_ip_address      = "192.168.10.${run.random.integer}"
    vm_nameservers     = []
    vm_search_domain   = ""
    vm_gateway_address = "192.168.10.1"

    tags = ["talos", "linux", "kubernetes"]
  }

  assert {
    condition    = proxmox_virtual_environment_vm.this.id == tostring(run.random.integer)
    error_message = "VM ID is not equal to the last digit of the IP address"
  }

  assert {
    condition    = proxmox_virtual_environment_vm.this.name == run.random.pet
    error_message = "VM ID is not equal to the last digit of the IP address"
  }
}
