output "cluster_id" {
  value = oci_containerengine_cluster.this.id
}

output "cluster_endpoint_public" {
  value = oci_containerengine_cluster.this.endpoints[0].public_endpoint
}

output "cluster_endpoint_private" {
  value = oci_containerengine_cluster.this.endpoints[0].private_endpoint
}

output "node_pool_id" {
  value = oci_containerengine_node_pool.pool.id
}
