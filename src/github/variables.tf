variable "gitignore_templates" {
  type        = string
  description = "Gitignore template to use, see https://github.com/github/gitignore"
  default     = "Terraform"
}

variable "license_template" {
  type        = string
  description = "Licence template to use, see https://github.com/github/choosealicense.com/tree/gh-pages/_licenses"
  default     = "mpl-2.0"
}

variable "topics" {
  type        = list(string)
  description = "Topics to add to the repository"
  default     = []
}
