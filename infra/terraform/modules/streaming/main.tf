resource "oci_streaming_stream" "this" {
  name           = var.stream_name
  partitions     = var.partitions
  compartment_id = var.compartment_ocid
  retention_in_hours = var.retention_in_hours
}
