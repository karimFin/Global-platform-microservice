variable "compartment_ocid" {
  type = string
}

variable "db_name" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "cpu_core_count" {
  type    = number
  default = 1
}

variable "data_storage_size_in_tbs" {
  type    = number
  default = 1
}
