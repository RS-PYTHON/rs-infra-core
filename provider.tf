variable "FE_username" {
    description = "flexibleengine username"
    type        = string
    sensitive   = false
}

variable "FE_password" {
    description = "flexibleengine password"
    type        = string
    sensitive   = true
}

variable "FE_domain" {
    description = "flexibleengine domain"
    type        = string
    sensitive   = false
}

variable "FE_region" {
    description = "flexibleengine region"
    type        = string
    sensitive   = false
}

variable "FE_access_key" {
    description = "flexibleengine access_key for OBS"
    type        = string
    sensitive   = false
}

variable "FE_secret_key" {
    description = "flexibleengine secret_key for OBS"
    type        = string
    sensitive   = true
}

terraform {
required_version = ">= 1.6.0"

required_providers {
  flexibleengine    = {
    source          = "FlexibleEngineCloud/flexibleengine"
    version         = ">= 1.43.0"
   }
 }
}

provider "flexibleengine" {
  user_name   = var.FE_username
  password    = var.FE_password
  domain_name = var.FE_domain
  region      = var.FE_region
  access_key  = var.FE_access_key
  secret_key  = var.FE_secret_key
}