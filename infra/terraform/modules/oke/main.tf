resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_ocid
  name               = var.name
  kubernetes_version = var.kubernetes_version
  vcn_id             = var.vcn_id
  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = var.subnet_ids[0]
  }
  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    admission_controller_options {
      is_pod_security_policy_enabled = false
    }
    service_lb_subnet_ids = [var.subnet_ids[0]]
  }
}

resource "oci_containerengine_node_pool" "pool" {
  compartment_id     = var.compartment_ocid
  cluster_id         = oci_containerengine_cluster.this.id
  name               = "${var.name}-pool"
  kubernetes_version = var.kubernetes_version
  node_config_details {
    size = var.node_pool_size
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id = var.subnet_ids[0]
    }
    is_pv_encryption_in_transit_enabled = true
  }
  node_shape = var.node_shape
  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_gbs
  }
}
