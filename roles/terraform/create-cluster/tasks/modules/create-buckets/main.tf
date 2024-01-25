terraform {
required_version = ">= 1.6.0"

required_providers {
  flexibleengine    = {
    source          = "FlexibleEngineCloud/flexibleengine"
    version         = ">= 1.45.0"
   }
 }
}

variable "cluster_name" {
    description = "cluster name"
    type        = string
}

variable "buckets" {
    description = "bucket list"
    type        = list(string)
}

resource "flexibleengine_s3_bucket" "buckets" {
  for_each = toset(var.buckets)
  bucket = "${var.cluster_name}-${each.value}"
}