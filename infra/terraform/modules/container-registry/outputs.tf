output "repository_id" {
  value = oci_artifacts_container_repository.repo.id
}

output "repository_path" {
  value = oci_artifacts_container_repository.repo.display_name
}
