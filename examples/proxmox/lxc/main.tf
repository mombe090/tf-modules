module "lxc" {
  source         = "../../../src/proxmox/lxc"
  hostname       = "my-test-container"
  id             = 1234
  ip_address     = "192.168.10.123"
  password       = "test123"
  download_image = false #to true if image is not already downloaded
}
