output "autonomous_db_id" {
  value = oci_database_autonomous_database.this.id
}

output "autonomous_db_connection_strings" {
  value = oci_database_autonomous_database.this.connection_strings
}
