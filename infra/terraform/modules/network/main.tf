resource "oci_core_vcn" "this" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "gmp-vcn"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  enabled        = true
  display_name   = "gmp-igw"
}

resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "gmp-public-rt"
  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "gmp-public-sl"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 0
      max = 65535
    }
  }
}

resource "oci_core_security_list" "private_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "gmp-private-sl"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_cidr
  }
}

resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.this.id
  cidr_block        = var.public_subnet_cidr
  display_name      = "gmp-public-subnet"
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "private" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.this.id
  cidr_block        = var.private_subnet_cidr
  display_name      = "gmp-private-subnet"
  security_list_ids = [oci_core_security_list.private_sl.id]
  prohibit_public_ip_on_vnic = true
}
