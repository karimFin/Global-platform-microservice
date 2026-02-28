variable "compartment_ocid" {
  type = string
}

variable "stream_name" {
  type = string
}

variable "partitions" {
  type    = number
  default = 3
}

variable "retention_in_hours" {
  type    = number
  default = 24
}
