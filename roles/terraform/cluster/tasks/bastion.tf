# Copyright 2023-2025 Airbus, CS Group
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

# Bastion part

resource "openstack_compute_keypair_v2" "keypair" {
  provider   = openstack.ovh
  name       = "keypair-${var.cluster_name}"
  public_key = var.public_key
}

resource "openstack_compute_instance_v2" "bastion" {
  provider    = openstack.ovh
  name        = "bastion-${var.cluster_name}"
  flavor_name = "b3-8"
  image_name  = "Ubuntu 24.04"
  key_pair    = openstack_compute_keypair_v2.keypair.name
  region      = "GRA11"

  network {
    name = "Ext-Net"
  }

  security_groups = [
    openstack_networking_secgroup_v2.bastion_sg.name
  ]
}

# Output part

output "bastion_ip" {
  value = openstack_compute_instance_v2.bastion.network[0].fixed_ip_v4
}
