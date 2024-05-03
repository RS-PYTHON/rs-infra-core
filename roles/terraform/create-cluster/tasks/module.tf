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

# create-cluster module
variable "image_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_gateway_ip" {
  type = string
}

variable "vpc_subnet_cidr" {
  type = string
}

variable "vpc_subnet_primary_dns" {
  type = string
}

variable "vpc_subnet_secondary_dns" {
  type = string
}

variable "nat_gw_spec" {
  type = string
}

variable "eip_nat_gw_type" {
  type = string
}

variable "eip_nat_gw_bandwidth" {
  type = number
}

variable "eip_elb_type" {
  type = string
}

variable "eip_elb_bandwidth" {
  type = number
}

variable "public_key" {
  type = string
}

variable "cluster_configuration" {
    description = "infrastructure configuration"
    type        = map(object({
      flavor    = string
      amount    = number
      type      = string
      k8s_roles = string
      additionnal_disk_size = number
    }))
}

output "hosts" {
  value = "${module.create-cluster.hosts}"
}

output "eip_addr" {
  value = "${module.create-cluster.eip_addr}"
}

module "create-cluster" {
    source = "./modules/create-cluster"
    image_name = var.image_name
    vpc_cidr = var.vpc_cidr
    vpc_gateway_ip = var.vpc_gateway_ip
    vpc_subnet_cidr = var.vpc_subnet_cidr
    vpc_subnet_primary_dns = var.vpc_subnet_primary_dns
    vpc_subnet_secondary_dns = var.vpc_subnet_secondary_dns
    cluster_configuration = var.cluster_configuration
    cluster_name = var.cluster_name
    public_key = var.public_key
    nat_gw_spec = var.nat_gw_spec
    eip_nat_gw_type = var.eip_nat_gw_type
    eip_nat_gw_bandwidth = var.eip_nat_gw_bandwidth
    eip_elb_type = var.eip_elb_type
    eip_elb_bandwidth = var.eip_elb_bandwidth
}

#create-buckets module

variable "cluster_name" {
    description = "cluster name"
    type        = string
}

variable "buckets" {
    description = "bucket list"
    type        = list(string)
}

module "create-buckets" {
    source = "./modules/create-buckets"
    buckets = var.buckets
    cluster_name = var.cluster_name
}