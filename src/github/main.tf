resource "github_repository" "tf_modules" {
  name        = "tf-modules"
  description = "This repository contains Terraform modules"

  visibility = "public"

  allow_squash_merge  = true
  allow_update_branch = true

  auto_init          = true
  gitignore_template = var.gitignore_templates
  license_template   = var.license_template
  archive_on_destroy = true
  topics             = var.topics
}

resource "github_repository_ruleset" "tf_modules" {
  name        = "tf-modules"
  repository  = github_repository.tf_modules.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  rules {
    creation                = true
    update                  = true
    deletion                = true
    required_linear_history = true
  }
}







resource "github_repository" "docs" {
  name        = "techdocs"
  description = "My technical documentation"

  visibility = "public"

  allow_squash_merge  = true
  allow_update_branch = true

  auto_init          = true
  gitignore_template = var.gitignore_templates
  license_template   = var.license_template
  archive_on_destroy = true
  topics             = var.topics
}
