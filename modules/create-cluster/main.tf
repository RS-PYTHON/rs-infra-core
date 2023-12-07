terraform {
required_version = ">= 1.6.0"

required_providers {
  flexibleengine    = {
    source          = "FlexibleEngineCloud/flexibleengine"
    version         = ">= 1.43.0"
   }
 }
}

variable "image_name" {
    description = "image name"
    type        = string
}

variable "master_flavor" {
    description = "master flavor"
    type        = string
}

variable "master_amount" {
    description = "number of gateway to create"
    type        = number
}

variable "gateway_flavor" {
    description = "gateway flavor"
    type        = string
}

variable "gateway_amount" {
    description = "number of gateway to create"
    type        = number
}

variable "infra_flavor" {
    description = "infra flavor"
    type        = string
}

variable "infra_amount" {
    description = "number of infra to create"
    type        = number
}


resource "flexibleengine_compute_instance_v2" "master" {
  name            = "master"
  image_name      = var.image_name
  flavor_id       = var.master_flavor
  key_pair        = "my_key_pair_name"
  security_groups = ["default"]
  count           = var.master_amount

  network {
    uuid = flexibleengine_vpc_v1.main_vpc.id
  }

  tags = {
    type  = "master"
  }
}

resource "flexibleengine_compute_instance_v2" "gateway" {
  name            = "gateway"
  image_name      = var.image_name
  flavor_id       = var.gateway_flavor
  key_pair        = "my_key_pair_name"
  security_groups = ["default"]
  count           = var.gateway_amount

  network {
    uuid = flexibleengine_vpc_v1.main_vpc.id
  }

  tags = {
    type  = "gateway"
  }
}

resource "flexibleengine_compute_instance_v2" "infra" {
  name            = "infra"
  image_name      = var.image_name
  flavor_id       = var.infra_flavor
  key_pair        = "my_key_pair_name"
  security_groups = ["default"]
  count           = var.infra_amount

  network {
    uuid = flexibleengine_vpc_v1.main_vpc.id
  }

  tags = {
    type  = "infra"
  }
}

variable "vpc_cidr" {
    description = "network cidr"
    type        = string
}

resource "flexibleengine_vpc_v1" "main_vpc" {
  name = "main_vpc"
  cidr = var.vpc_cidr
}
