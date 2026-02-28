resource "oci_database_autonomous_database" "this" {
  compartment_id            = var.compartment_ocid
  db_name                   = var.db_name
  cpu_core_count            = var.cpu_core_count
  data_storage_size_in_tbs  = var.data_storage_size_in_tbs
  admin_password            = var.admin_password
  is_free_tier              = true
  db_workload               = "OLTP"
  license_model             = "LICENSE_INCLUDED"
}
