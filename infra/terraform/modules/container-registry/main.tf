resource "oci_artifacts_container_repository" "repo" {
  compartment_id = var.compartment_ocid
  display_name   = var.display_name
  is_immutable   = false
  is_public      = false
}
