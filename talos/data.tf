data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = true
  }
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_image_version
  filters = {
    names = var.talos_tools_extensions
  }
}

data "talos_image_factory_urls" "this" {
  talos_version = var.talos_image_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "nocloud"
}
