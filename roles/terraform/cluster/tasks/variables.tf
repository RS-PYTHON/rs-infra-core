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

# Variables part

variable "cluster_name" {
    description = "cluster name"
    type        = string
}

variable "region" {
    description = "OVH region"
    type        = string
}

variable "allowed_ip_list" {
    description = "list of allowed ip"
    type        = list(string)
}

variable "nodepool_infra_desired_nodes" {
    description = "number of desired nodes on nodepool"
    type        = number
    default     = 0
}

variable "nodepool_infra_autoscale" {
    description = "Enable autoscaling of nodepool"
    type        = bool
    default     = true
}

variable "nodepool_processing_desired_nodes" {
    description = "number of desired nodes on nodepool"
    type        = number
    default     = 0
}

variable "nodepool_processing_autoscale" {
    description = "Enable autoscaling of nodepool"
    type        = bool
    default     = true
}

variable "nodepool_access_csc_desired_nodes" {
    description = "number of desired nodes on nodepool"
    type        = number
    default     = 0
}

variable "nodepool_access_csc_autoscale" {
    description = "Enable autoscaling of nodepool"
    type        = bool
    default     = true
}

variable "nodepool_prefect_desired_nodes" {
    description = "number of desired nodes on nodepool"
    type        = number
    default     = 0
}

variable "nodepool_prefect_autoscale" {
    description = "Enable autoscaling of nodepool"
    type        = bool
    default     = true
}

variable "nodepool_processing_ondemand_desired_nodes" {
    description = "number of desired nodes on nodepool"
    type        = number
    default     = 0
}

variable "nodepool_processing_ondemand_autoscale" {
    description = "Enable autoscaling of nodepool"
    type        = bool
    default     = true
}

variable "nodepool_processing_systematic_desired_nodes" {
    description = "number of desired nodes on nodepool"
    type        = number
    default     = 0
}

variable "nodepool_processing_systematic_autoscale" {
    description = "Enable autoscaling of nodepool"
    type        = bool
    default     = true
}

variable "buckets" {
    description = "bucket list"
    type        = list(string)
}

variable "buckets_region" {
    description = "buckets region"
    type        = string
}

variable "public_key" {
    description = "public_key"
    type = string
}