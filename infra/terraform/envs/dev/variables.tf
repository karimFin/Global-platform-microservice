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
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "bucket_name" {
  type    = string
  default = "gmp-events"
}

variable "enable_object_storage" {
  type    = bool
  default = false
}

variable "stream_name" {
  type    = string
  default = "gmp-events"
}

variable "enable_streaming" {
  type    = bool
  default = false
}

variable "enable_container_registry" {
  type    = bool
  default = false
}

variable "enable_autonomous_db" {
  type    = bool
  default = false
}

variable "adb_admin_password" {
  type      = string
  default   = null
  nullable  = true
  sensitive = true
}

variable "oke_kubernetes_version" {
  type    = string
  default = "v1.32.10"
}

variable "oke_node_pool_size" {
  type    = number
  default = 1
}

variable "oke_node_shape" {
  type    = string
  default = "VM.Standard.E5.Flex"
}

variable "oke_node_ocpus" {
  type    = number
  default = 1
}

variable "oke_node_memory_gbs" {
  type    = number
  default = 8
}

variable "oke_node_image_id" {
  type    = string
  default = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaahpirzwiyczbswqzmb6zfla33hjzcedqm3vawqbcul5bixwyboona"
}
