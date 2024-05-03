# Copyright 2024 CS Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

backend "s3" {
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_s3_checksum            = true
}

required_providers {
  flexibleengine    = {
    source          = "FlexibleEngineCloud/flexibleengine"
    version         = ">= 1.45.0"
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