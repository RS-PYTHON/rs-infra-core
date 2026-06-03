# Copyright 2023-2026 Airbus, CS Group
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
  default     = "rs-cluster"
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
  description = "Number of desired nodes on nodepool infra"
  type        = number
  default     = 0
}

variable "nodepool_rs_server_desired_nodes" {
  description = "Number of desired nodes on nodepool rs server"
  type        = number
  default     = 0
}

variable "nodepool_rs_env_desired_nodes" {
  description = "Number of desired nodes on nodepool rs env"
  type        = number
  default     = 0
}

variable "nodepool_access_csc_desired_nodes" {
  description = "Number of desired nodes on nodepool access csc"
  type        = number
  default     = 0
}

variable "nodepool_prefect_flow_desired_nodes" {
  description = "Number of desired nodes on nodepool prefect flow"
  type        = number
  default     = 0
}

variable "nodepool_dask_scheduler_desired_nodes" {
  description = "Number of desired nodes on nodepool dask scheduler"
  type        = number
  default     = 0
}

variable "nodepool_dask_worker_on_demand_desired_nodes" {
  description = "Number of desired nodes on nodepool dask worker on demand"
  type        = number
  default     = 0
}

variable "nodepool_infra_autoscale" {
  description = "Enable autoscaling of nodepool infra"
  type        = bool
  default     = true
}

variable "nodepool_rs_server_autoscale" {
  description = "Enable autoscaling of nodepool rs server"
  type        = bool
  default     = true
}

variable "nodepool_rs_env_autoscale" {
  description = "Enable autoscaling of nodepool rs env"
  type        = bool
  default     = true
}

variable "nodepool_access_csc_autoscale" {
  description = "Enable autoscaling of nodepool access csc"
  type        = bool
  default     = true
}

variable "nodepool_prefect_flow_autoscale" {
  description = "Enable autoscaling of nodepool prefect flow"
  type        = bool
  default     = true
}

variable "nodepool_dask_scheduler_autoscale" {
  description = "Enable autoscaling of nodepool dask scheduler"
  type        = bool
  default     = true
}

variable "nodepool_dask_worker_on_demand_autoscale" {
  description = "Enable autoscaling of nodepool dask worker on demand"
  type        = bool
  default     = true
}

variable "nodepool_prefect_flow_min_nodes" {
  description = "Number of minimal nodes on nodepool prefect flow"
  type        = number
  default     = 0
}

variable "nodepool_access_csc_max_nodes" {
  description = "Number of desired nodes on nodepool access csc"
  type        = number
  default     = 5
}

variable "nodepool_dask_scheduler_max_nodes" {
  description = "Number of maximum nodes on nodepool dask scheduler"
  type        = number
  default     = 1
}

variable "nodepool_dask_worker_on_demand_max_nodes" {
  description = "Number of max nodes on nodepool dask worker on demand"
  type        = number
  default     = 8
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
  type        = string
}
