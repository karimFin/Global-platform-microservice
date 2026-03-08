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
  count            = var.enable_object_storage ? 1 : 0
  source           = "../../modules/object-storage"
  compartment_ocid = var.compartment_ocid
  bucket_name      = var.bucket_name
}

module "streaming" {
  count            = var.enable_streaming ? 1 : 0
  source           = "../../modules/streaming"
  compartment_ocid = var.compartment_ocid
  stream_name      = var.stream_name
}

module "container_registry" {
  count            = var.enable_container_registry ? 1 : 0
  source           = "../../modules/container-registry"
  compartment_ocid = var.compartment_ocid
  display_name     = "gmp"
}

module "autonomous_db" {
  count                    = var.enable_autonomous_db ? 1 : 0
  source                   = "../../modules/autonomous-db"
  compartment_ocid         = var.compartment_ocid
  db_name                  = "gmpdb"
  admin_password           = var.adb_admin_password
  cpu_core_count           = 0
  data_storage_size_in_tbs = 1
}

module "oke" {
  source                = "../../modules/oke"
  compartment_ocid      = var.compartment_ocid
  name                  = "gmp-oke-dev"
  vcn_id                = module.network.vcn_id
  endpoint_subnet_id    = module.network.public_subnet_id
  service_lb_subnet_ids = [module.network.public_subnet_id]
  node_subnet_id        = module.network.private_subnet_id
  availability_domain   = data.oci_identity_availability_domains.ads.availability_domains[0].name
  kubernetes_version    = var.oke_kubernetes_version
  node_pool_size        = var.oke_node_pool_size
  node_shape            = var.oke_node_shape
  node_ocpus            = var.oke_node_ocpus
  node_memory_gbs       = var.oke_node_memory_gbs
  node_image_id         = var.oke_node_image_id
}
