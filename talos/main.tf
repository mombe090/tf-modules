resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
        }
      }
    }
  )
}

resource "null_resource" "this" {
  connection {
    type        = "ssh"
    host        = var.proxmox_server_ip_adresse
    user        = var.proxmox_user
    private_key = file(var.proxmox_user_ssh_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/scripts/download-talos.sh"
    destination = "download-talos.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x download-talos.sh",
      "./download-talos.sh ${data.talos_image_factory_urls.this.urls["disk_image"]} ${var.refresh_talos_image_in_proxmox}",
    ]
  }

  triggers = {
    refresh_talos_image = var.refresh_talos_image_in_proxmox
  }
}
