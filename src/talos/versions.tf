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
      version = "0.7.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_server_ip_adresse}:${var.proxmox_server_port}/"

  # si vous avez un certificat auto-signé, il faut mettre cette ligne à true
  insecure = true

  # bgp utilise un accès pour exécuter la cli de proxmox qm/pvesm ... pour créer les VM car l'API est limité.
  # Il faut noter qu'avec l'adoption en masse de proxmox, l'API vas surement être amélioré.
  ssh {
    agent = true
  }
}
