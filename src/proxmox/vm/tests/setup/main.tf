terraform {
  required_version = ">= 1.9.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.1"
    }
  }
}

resource "random_integer" "this" {
  min = 115
  max = 120
}

resource "random_pet" "this" {
  length = "10"
  prefix = "vm-"
}

#tflint-ignore: terraform_standard_module_structure
output "integer" {
  value       = random_integer.this.result
  description = "A random integer between 115 and 120"
}

#tflint-ignore: terraform_standard_module_structure
output "pet" {
  value       = random_pet.this.id
  description = "A random pet name to use as VM name"
}
