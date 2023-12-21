terraform {
required_version = ">= 1.6.0"
backend "s3" {
  bucket   = "terraformbucket"
  key      = "terraform.tfstate"
  region   = "eu-west-0"
  endpoint = "https://oss.eu-west-0.prod-cloud-ocb.orange-business.com"
  
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
}

required_providers {
  flexibleengine    = {
    source          = "FlexibleEngineCloud/flexibleengine"
    version         = ">= 1.43.0"
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