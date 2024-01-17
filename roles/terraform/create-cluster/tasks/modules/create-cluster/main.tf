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

variable "cluster_name" {
    description = "cluster name"
    type        = string
}

variable "public_key" {
    description = "public key"
    type        = string
}

variable "cluster_configuration" {
    description = "infrastructure configuration"
    type        = map(object({
      flavor                = string
      amount                = number
      type                  = string
      k8s_role              = string
      additionnal_disk_size = number
    }))
}

resource "flexibleengine_compute_instance_v2" "nodes" {
  for_each = {
    for item in flatten([
      for nodes in var.cluster_configuration : [
        for count in range(nodes.amount) : {
          name                  = nodes.type
          flavor                = nodes.flavor
          number                = count
          additionnal_disk_size = nodes.additionnal_disk_size
          k8s_role              = nodes.k8s_role
        }
      ]
    ])
    : "${item.name}.${item.number}" => item
  }
  name            = "${var.cluster_name}-${each.value.name}-${each.value.number}"
  image_name      = var.image_name
  flavor_id       = each.value.flavor
  key_pair        = "${var.cluster_name}-keypair"
  security_groups = [flexibleengine_networking_secgroup_v2.secgroup.name]
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
    type     = each.value.name
    k8s_role = each.value.k8s_role
  }
  depends_on = [
    flexibleengine_compute_keypair_v2.keypair
  ]
}

resource "flexibleengine_compute_keypair_v2" "keypair" {
  name       = "${var.cluster_name}-keypair"
  public_key = var.public_key
}

#Network configuration
variable "vpc_cidr" {
  type = string
}

variable "vpc_gateway_ip" {
  type = string
}

variable "vpc_subnet_cidr" {
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

resource "flexibleengine_vpc_v1" "main_vpc" {
  name = "main_vpc"
  cidr = var.vpc_cidr
}

resource "flexibleengine_vpc_subnet_v1" "vpc_subnet" {
  name       = "vpc_subnet"
  cidr       = var.vpc_subnet_cidr
  gateway_ip = var.vpc_gateway_ip
  vpc_id     = flexibleengine_vpc_v1.main_vpc.id
}

resource "flexibleengine_nat_gateway_v2" "nat_gateway" {
  name      = "nat_test"
  spec      = var.nat_gw_spec
  vpc_id    = flexibleengine_vpc_v1.main_vpc.id
  subnet_id = flexibleengine_vpc_subnet_v1.vpc_subnet.id
}

resource "flexibleengine_nat_snat_rule_v2" "snat_rule" {
  nat_gateway_id = flexibleengine_nat_gateway_v2.nat_gateway.id
  floating_ip_id = flexibleengine_vpc_eip.eip_nat_gw.id
  subnet_id      = flexibleengine_vpc_subnet_v1.vpc_subnet.id
}

resource "flexibleengine_vpc_eip" "eip_nat_gw" {
  publicip {
    type = var.eip_nat_gw_type
  }
  bandwidth {
    name       = "bandwidth_nat_gw"
    size       = var.eip_nat_gw_bandwidth
    share_type = "PER"
  }
}

resource "flexibleengine_networking_secgroup_v2" "secgroup" {
  name = "secgroup"
}

resource "flexibleengine_networking_secgroup_rule_v2" "allow_ssh_ingress" {
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
    "eu-west-0b"
  ]
  ipv4_eip_id = flexibleengine_vpc_eip.elb_eip.id

  backend_subnets   = [
    flexibleengine_vpc_subnet_v1.vpc_subnet.id
  ]
}

resource "flexibleengine_vpc_eip" "elb_eip" {
  publicip {
    type = var.eip_elb_type
  }
  bandwidth {
    name       = "bandwidth_elb"
    size       = var.eip_elb_bandwidth
    share_type = "PER"
  }
}

resource "flexibleengine_lb_listener_v3" "listener" {
  name            = "elb-listener"
  description     = "listener"
  protocol        = "TCP"
  protocol_port   = 22
  loadbalancer_id = flexibleengine_lb_loadbalancer_v3.elb.id
}

resource "flexibleengine_lb_pool_v3" "pool" {
  protocol    = "TCP"
  lb_method   = "SOURCE_IP"
  listener_id = flexibleengine_lb_listener_v3.listener.id
}

resource "flexibleengine_lb_member_v3" "member" {
  address       = flexibleengine_compute_instance_v2.nodes["master.0"].access_ip_v4
  protocol_port = 22
  pool_id       = flexibleengine_lb_pool_v3.pool.id
  subnet_id     = flexibleengine_vpc_subnet_v1.vpc_subnet.ipv4_subnet_id
}

output "eip_addr" {
  value = flexibleengine_vpc_eip.elb_eip.address
}

output "hosts" {
  description = "Hosts.yaml creation"
  value       = flexibleengine_compute_instance_v2.nodes
}