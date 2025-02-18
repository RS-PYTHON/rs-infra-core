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
    type        = string
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