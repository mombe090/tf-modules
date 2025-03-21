terraform {
  required_version = ">= 1.9.0"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = ">= 3.2.1"
    }
  }
}

#tflint-ignore: terraform_standard_module_structure
variable "kube_url" {
  type        = string
  description = "URL of the kubernetes API to validate"
}

data "http" "validation" {
  url = var.kube_url
  #ca_cert_pem        = var.kube_ca
  request_timeout_ms = 5000
  insecure           = true

  request_headers = {
    Accept = "application/json"
  }
}

#tflint-ignore: terraform_standard_module_structure
output "status_code" {
  value       = data.http.validation.status_code
  description = "Status code of the kubernetes API response"
}
