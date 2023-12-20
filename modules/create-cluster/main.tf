terraform {
required_version = ">= 1.6.0"

required_providers {
  flexibleengine    = {
    source          = "FlexibleEngineCloud/flexibleengine"
    version         = ">= 1.43.0"
   }
 }
}

#Instances configuration
variable "image_name" {
    description = "image name"
    type        = string
}

variable "cluster_configuration" {
    description = "infrastructure configuration"
    type        = map(object({
      flavor    = string
      amount    = number
      type      = string
      additionnal_disk_size = number
    }))
}



resource "flexibleengine_compute_instance_v2" "nodes" {
  for_each = {
    for item in flatten([
      for nodes in var.cluster_configuration : [
        for count in range(nodes.amount) : {
          name  = nodes.type
          flavor = nodes.flavor
          number = count
          additionnal_disk_size = nodes.additionnal_disk_size
        }
      ]
    ])
    : "${item.name}.${item.flavor}.${item.number}" => item
  }
  name            = "${each.value.name}-${each.value.number}"
  image_name      = var.image_name
  flavor_id       = each.value.flavor
  network {
    uuid = flexibleengine_vpc_subnet_v1.vpc_subnet.id
  }
  dynamic "block_device"{
    for_each = each.value.additionnal_disk_size > 0 ? ["1"] : []
    content {
      source_type           = "blank"
      destination_type      = "volume"
      volume_size           = each.value.additionnal_disk_size
      boot_index            = 1
      delete_on_termination = true
    }
  }
  tags = {
    type  = each.value.name
  }
}


#Network configuration
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

resource "flexibleengine_nat_gateway_v2" "nat_gateway" {
  name        = "nat_test"
  description = "test for terraform"
  spec        = "1"
  vpc_id      = flexibleengine_vpc_v1.main_vpc.id
  subnet_id   = flexibleengine_vpc_subnet_v1.vpc_subnet.id
}

resource "flexibleengine_network_acl_rule" "rule_1" {
  name             = "my-rule-1"
  description      = "drop TELNET traffic"
  action           = "deny"
  protocol         = "tcp"
  destination_port = "23"
  enabled          = "true"
}

resource "flexibleengine_network_acl_rule" "rule_2" {
  name             = "my-rule-2"
  description      = "drop NTP traffic"
  action           = "deny"
  protocol         = "udp"
  destination_port = "123"
  enabled          = "false"
}

resource "flexibleengine_network_acl" "fw_acl" {
  name          = "fw-acl"
  subnets       = [flexibleengine_vpc_subnet_v1.vpc_subnet.id]
  outbound_rules = [flexibleengine_network_acl_rule.rule_1.id,
    flexibleengine_network_acl_rule.rule_2.id]
}