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
  name            = "master-${count.index}"
  image_name      = var.image_name
  flavor_id       = var.master_flavor
  security_groups = ["default"]
  count           = var.master_amount

  network {
    uuid = flexibleengine_vpc_subnet_v1.vpc_subnet.id
  }

  tags = {
    type  = "master"
  }
}

resource "flexibleengine_nat_gateway_v2" "nat_1" {
  name        = "nat_test"
  description = "test for terraform"
  spec        = "1"
  vpc_id      = flexibleengine_vpc_v1.main_vpc.id
  subnet_id   = flexibleengine_vpc_subnet_v1.vpc_subnet.id
}

resource "flexibleengine_compute_instance_v2" "infra" {
  name            = "infra-${count.index}"
  image_name      = var.image_name
  flavor_id       = var.infra_flavor
  key_pair        = "my_key_pair_name"
  security_groups = ["default"]
  count           = var.infra_amount

  network {
    uuid = flexibleengine_vpc_subnet_v1.vpc_subnet.id
  }

  tags = {
    type  = "infra"
  }
}

variable "vpc_cidr" {
    description = "network cidr"
    type        = string
}

variable "vpc_subnet_cidr" {
    description = "subnet cidr"
    type        = string
}

resource "flexibleengine_vpc_v1" "main_vpc" {
  name = "main_vpc"
  cidr = var.vpc_cidr
}

resource "flexibleengine_vpc_subnet_v1" "vpc_subnet" {
  name       = "vpc_subnet"
  cidr       = var.vpc_subnet_cidr
  gateway_ip = "192.168.0.1"
  vpc_id     = flexibleengine_vpc_v1.main_vpc.id
}
