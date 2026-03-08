variable "github_owner" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "repository_name" {
  type    = string
  default = "gpm-microservices"
}

variable "preview_label_color" {
  type    = string
  default = "0e8a16"
}

variable "dev_required_status_checks" {
  type = list(string)
  default = [
    "ci",
    "ci-extended"
  ]
}

variable "main_required_status_checks" {
  type = list(string)
  default = [
    "ci",
    "ci-extended"
  ]
}

variable "tf_cloud_organization" {
  type    = string
  default = ""
}

variable "tf_workspace" {
  type    = string
  default = "gmp-dev"
}

variable "required_environment_secrets" {
  type = map(list(string))
  default = {
    dev = [
      "KUBE_CONFIG_DEV",
      "TF_API_TOKEN"
    ]
    prod = [
      "KUBE_CONFIG_PROD"
    ]
  }
}

variable "declared_environment_secret_names" {
  type = map(list(string))
  default = {
    dev = [
      "KUBE_CONFIG_DEV",
      "TF_API_TOKEN",
      "OCI_CLI_USER",
      "OCI_CLI_TENANCY",
      "OCI_CLI_FINGERPRINT",
      "OCI_CLI_KEY_CONTENT",
      "OCI_CLI_REGION",
      "GHCR_TOKEN"
    ]
    prod = [
      "KUBE_CONFIG_PROD",
      "OCI_CLI_USER",
      "OCI_CLI_TENANCY",
      "OCI_CLI_FINGERPRINT",
      "OCI_CLI_KEY_CONTENT",
      "OCI_CLI_REGION",
      "GHCR_TOKEN"
    ]
  }
}

variable "managed_environment_secrets" {
  type      = map(map(string))
  default   = {}
  sensitive = true
}
