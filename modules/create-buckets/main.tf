terraform {
required_version = ">= 1.6.0"

required_providers {
  flexibleengine    = {
    source          = "FlexibleEngineCloud/flexibleengine"
    version         = ">= 1.43.0"
   }
 }
}

variable "buckets" {
    description = "bucket list"
    type        = list(string)
}

resource "flexibleengine_s3_bucket" "buckets" {
  for_each = toset(var.buckets)
  bucket = each.value
}