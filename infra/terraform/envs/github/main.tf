data "github_repository" "this" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

resource "github_issue_label" "preview" {
  repository  = var.repository_name
  name        = "preview"
  color       = var.preview_label_color
  description = "Deploy ephemeral preview environment"
}

resource "github_issue_label" "iac" {
  repository  = var.repository_name
  name        = "iac"
  color       = "1d76db"
  description = "Infrastructure as Code change"
}

resource "github_issue_label" "reliability" {
  repository  = var.repository_name
  name        = "reliability"
  color       = "d73a4a"
  description = "Reliability and SRE focused change"
}

resource "github_branch_protection" "dev" {
  repository_id  = data.github_repository.this.node_id
  pattern        = "dev"
  enforce_admins = true

  allows_deletions    = false
  allows_force_pushes = false

  required_status_checks {
    strict   = true
    contexts = var.dev_required_status_checks
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}

resource "github_branch_protection" "main" {
  repository_id  = data.github_repository.this.node_id
  pattern        = "main"
  enforce_admins = true

  allows_deletions    = false
  allows_force_pushes = false

  required_status_checks {
    strict   = true
    contexts = var.main_required_status_checks
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}

resource "github_repository_environment" "dev" {
  repository  = var.repository_name
  environment = "dev"

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = false
  }
}

resource "github_repository_environment" "prod" {
  repository  = var.repository_name
  environment = "prod"
  wait_timer  = 10

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

resource "github_actions_environment_variable" "dev_tf_org" {
  count = var.tf_cloud_organization == "" ? 0 : 1

  repository    = var.repository_name
  environment   = github_repository_environment.dev.environment
  variable_name = "TF_CLOUD_ORGANIZATION"
  value         = var.tf_cloud_organization
}

resource "github_actions_environment_variable" "dev_tf_workspace" {
  repository    = var.repository_name
  environment   = github_repository_environment.dev.environment
  variable_name = "TF_WORKSPACE"
  value         = var.tf_workspace
}
