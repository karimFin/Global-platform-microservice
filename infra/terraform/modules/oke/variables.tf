variable "compartment_ocid" {
  type = string
}

variable "name" {
  type = string
}

variable "vcn_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "availability_domain" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "v1.29.1"
}

variable "node_shape" {
  type    = string
  default = "VM.Standard.E4.Flex"
}

variable "node_ocpus" {
  type    = number
  default = 1
}

variable "node_memory_gbs" {
  type    = number
  default = 8
}

variable "node_pool_size" {
  type    = number
  default = 1
}
