terraform {
required_version = ">= 1.6.0"

backend "s3" {
  bucket   = "terraformbucket"
  key      = "terraform.tfstate"
  region   = "eu-west-0"
  endpoint = "https://oss.eu-west-0.prod-cloud-ocb.orange-business.com"
  
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
}

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
  security_groups = [var.secgroup.name]
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

resource "flexibleengine_networking_secgroup_v2" "secgroup" {
  name        = "secgroup"
}

resource "flexibleengine_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = flexibleengine_networking_secgroup_v2.secgroup.id
}

resource "flexibleengine_lb_loadbalancer_v3" "elb" {
  name              = "elb"
  cross_vpc_backend = true

  vpc_id            = flexibleengine_vpc_v1.main_vpc.id
  ipv4_subnet_id    = flexibleengine_vpc_subnet_v1.vpc_subnet.ipv4_subnet_id

  availability_zone = [
    "eu-west-0a",
  ]

  bandwidth_charge_mode = "traffic"
  sharetype             = "PER"
  bandwidth_size        = 10
}