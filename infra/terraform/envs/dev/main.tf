module "network" {
  source              = "../../modules/network"
  compartment_ocid    = var.compartment_ocid
  vcn_cidr            = var.vcn_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "object_storage" {
  source           = "../../modules/object-storage"
  compartment_ocid = var.compartment_ocid
  bucket_name      = var.bucket_name
}

module "streaming" {
  source           = "../../modules/streaming"
  compartment_ocid = var.compartment_ocid
  stream_name      = var.stream_name
}

module "container_registry" {
  source           = "../../modules/container-registry"
  compartment_ocid = var.compartment_ocid
  display_name     = "gmp"
}

module "autonomous_db" {
  source                   = "../../modules/autonomous-db"
  compartment_ocid         = var.compartment_ocid
  db_name                  = "gmpdb"
  admin_password           = var.adb_admin_password
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
}
