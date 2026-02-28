output "cluster_id" {
  value = oci_containerengine_cluster.this.id
}

output "kubeconfig" {
  value = oci_containerengine_cluster.this.endpoints
}
