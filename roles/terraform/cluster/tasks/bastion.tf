# Bastion part

 resource "openstack_compute_keypair_v2" "keypair" {
   provider = openstack.ovh
   name = "keypair-${var.cluster_name}"
   public_key = var.public_key
}

resource "openstack_compute_instance_v2" "bastion" {
  provider        = openstack.ovh
  name            = "bastion-${var.cluster_name}"
  flavor_name     = "b3-8"
  image_name      = "Ubuntu 24.04"
  key_pair        = openstack_compute_keypair_v2.keypair.name
  region          = "GRA11"

  network {
    uuid = openstack_networking_network_v2.private_net.id
  }

  network {
    name = "Ext-Net"
  }

  security_groups = [
    openstack_networking_secgroup_v2.bastion_sg.name
  ]
}

# Output part

output "bastion_ip" {
  value = openstack_compute_instance_v2.bastion.network[1].fixed_ip_v4
}
