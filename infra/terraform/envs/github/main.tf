data "github_repository" "this" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

locals {
  required_secret_environments = toset(keys(var.required_environment_secrets))
  declared_secret_environments = toset(keys(var.declared_environment_secret_names))
  managed_secret_environments  = toset(keys(var.managed_environment_secrets))
  managed_environment_secret_entries = flatten([
    for env_name, secret_map in var.managed_environment_secrets : [
      for secret_name, secret_value in secret_map : {
        key   = "${env_name}:${secret_name}"
        env   = env_name
        name  = secret_name
        value = secret_value
      }
    ]
  ])
}

check "required_secrets_are_declared" {
  assert {
    condition = alltrue([
      for env_name, required_names in var.required_environment_secrets :
      length(setsubtract(toset(required_names), toset(lookup(var.declared_environment_secret_names, env_name, [])))) == 0
    ])
    error_message = "required_environment_secrets must be included in declared_environment_secret_names for each environment."
  }
}

check "managed_secrets_are_declared" {
  assert {
    condition = alltrue([
      for env_name, secret_map in var.managed_environment_secrets :
      length(setsubtract(toset(keys(secret_map)), toset(lookup(var.declared_environment_secret_names, env_name, [])))) == 0
    ])
    error_message = "managed_environment_secrets contains secret names not listed in declared_environment_secret_names."
  }
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

resource "github_repository_environment" "secret_policy_environments" {
  for_each    = setsubtract(setunion(local.required_secret_environments, local.declared_secret_environments, local.managed_secret_environments), toset(["dev", "prod"]))
  repository  = var.repository_name
  environment = each.value

  deployment_branch_policy {
    protected_branches     = false
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

resource "github_actions_environment_variable" "secret_policy_required" {
  for_each = var.required_environment_secrets

  repository    = var.repository_name
  environment   = each.key
  variable_name = "REQUIRED_SECRETS"
  value         = join(",", each.value)

  depends_on = [
    github_repository_environment.dev,
    github_repository_environment.prod,
    github_repository_environment.secret_policy_environments
  ]
}

resource "github_actions_environment_variable" "secret_policy_declared" {
  for_each = var.declared_environment_secret_names

  repository    = var.repository_name
  environment   = each.key
  variable_name = "DECLARED_SECRETS"
  value         = join(",", each.value)

  depends_on = [
    github_repository_environment.dev,
    github_repository_environment.prod,
    github_repository_environment.secret_policy_environments
  ]
}

resource "github_actions_environment_secret" "managed" {
  for_each = {
    for entry in local.managed_environment_secret_entries : entry.key => entry
  }

  repository      = var.repository_name
  environment     = each.value.env
  secret_name     = each.value.name
  plaintext_value = each.value.value

  depends_on = [
    github_repository_environment.dev,
    github_repository_environment.prod,
    github_repository_environment.secret_policy_environments
  ]
}
