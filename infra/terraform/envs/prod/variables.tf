variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "region" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "vcn_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.1.2.0/24"
}

variable "bucket_name" {
  type    = string
  default = "gmp-events-prod"
}

variable "stream_name" {
  type    = string
  default = "gmp-events-prod"
}

variable "adb_admin_password" {
  type      = string
  sensitive = true
}

variable "oke_node_pool_size" {
  type    = number
  default = 2
}
