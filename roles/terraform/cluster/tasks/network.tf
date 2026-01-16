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

# Network part

resource "openstack_networking_network_v2" "private_net" {
  name           = "private-net-${var.cluster_name}"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = "private-subnet-${var.cluster_name}"
  network_id      = openstack_networking_network_v2.private_net.id
  cidr            = "192.168.1.0/24"
  ip_version      = 4
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

# Router
resource "openstack_networking_router_v2" "router" {
  name                = "router-${var.cluster_name}"
  admin_state_up      = true
  external_network_id = openstack_compute_instance_v2.bastion.network[0].uuid
}

# Attach Private Subnet to Router
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}

# Bastion Security Group
resource "openstack_networking_secgroup_v2" "bastion_sg" {
  name = "bastion-sg-${var.cluster_name}"
}

# Allow SSH from specific IPs
resource "openstack_networking_secgroup_rule_v2" "allow_ssh_restricted" {
  for_each          = toset(var.allowed_ip_list)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "${each.value}/32"
  security_group_id = openstack_networking_secgroup_v2.bastion_sg.id
}

# Kubernetes Security Group
resource "openstack_networking_secgroup_v2" "kubernetes_sg" {
  name = "kubernetes-sg-${var.cluster_name}"
}

# Allow Kubernetes API Access from Bastion
resource "openstack_networking_secgroup_rule_v2" "allow_k8s_api_from_bastion" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "${openstack_compute_instance_v2.bastion.network[0].fixed_ip_v4}/32"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_sg.id
}

# Allow HTTPS Access to Kubernetes
resource "openstack_networking_secgroup_rule_v2" "allow_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0" # Open to the public
  security_group_id = openstack_networking_secgroup_v2.kubernetes_sg.id
}
