# Ajout du provider bgp, ajuster s'il y a une nouvelle version
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.73.1"
    }

    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.9.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.3"
    }
  }
}
