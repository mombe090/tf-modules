output "latest_talos_stable_version" {
  value       = data.talos_image_factory_versions.this.talos_versions[length(data.talos_image_factory_versions.this.talos_versions) - 1]
  description = "Get the latest Talos stable version"
}

output "talos_installer_image_url" {
  value       = data.talos_image_factory_urls.this.urls["disk_image"]
  description = "Get the latest Talos installer image url for raw xz compressed image"
}
