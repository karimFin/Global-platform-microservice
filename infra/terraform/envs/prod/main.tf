data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

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
  display_name     = "gmp-prod"
}

module "autonomous_db" {
  source                   = "../../modules/autonomous-db"
  compartment_ocid         = var.compartment_ocid
  db_name                  = "gmpdbprod"
  admin_password           = var.adb_admin_password
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
}

module "oke" {
  source             = "../../modules/oke"
  compartment_ocid   = var.compartment_ocid
  name               = "gmp-oke-prod"
  vcn_id             = module.network.vcn_id
  subnet_ids         = [module.network.public_subnet_id]
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  kubernetes_version = "v1.29.1"
  node_pool_size     = var.oke_node_pool_size
}
