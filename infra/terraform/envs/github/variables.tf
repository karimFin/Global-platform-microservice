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
