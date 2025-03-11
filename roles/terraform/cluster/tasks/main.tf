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

# Define providers and set versions
terraform {
required_version    = ">= 1.6.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.42.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = "1.4.0"
    }
  }
  backend "s3" {
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/"
  domain_name = "default"
  alias       = "ovh"
}

provider "ovh" {
  alias = "ovh"
}

provider "aws" {
  region                      = var.buckets_region
  #OVH implementation has no STS service
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  # the gra region is unknown to AWS hence skipping is needed.
  skip_region_validation = true
  endpoints {
    s3 = "https://s3.${var.buckets_region}.io.cloud.ovh.net/"
  }
}