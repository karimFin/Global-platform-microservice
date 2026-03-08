terraform {
  required_version = ">= 1.5.0"
  cloud {}
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.33.0"
    }
  }
}
