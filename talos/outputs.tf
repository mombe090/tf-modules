output "latest_talos_stable_version" {
  value       = data.talos_image_factory_versions.this.talos_versions[length(data.talos_image_factory_versions.this.talos_versions) - 1]
  description = "Get the latest Talos stable version"
}

output "talos_installer_image_url" {
  value       = data.talos_image_factory_urls.this.urls["disk_image"]
  description = "Get the latest Talos installer image url for raw xz compressed image"
}

output "talos_client_config" {
  description = "Talos client configuration containing the talosconfig"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "k8s_config" {
  description = "Kubernetes client configuration containing the kubeconfig"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}
