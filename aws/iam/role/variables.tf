variable "role_name" {
  type = string
  description = "The name of the role"
}

variable "service_name" {
  type = string
  description = "The name of the service that assumes this role"
}

variable "policies_to_attach" {
  type = list(map(string))
  description = "The policies to attach to the role"
  default = []
}