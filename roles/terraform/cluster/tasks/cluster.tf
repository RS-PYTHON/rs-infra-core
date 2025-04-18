# Copyright 2024 CS Group
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

# Cluster part

resource "ovh_cloud_project_kube" "cluster" {
  name         = "${var.cluster_name}"
  region       = "${var.region}"
  private_network_id = openstack_networking_network_v2.private_net.id
  nodes_subnet_id = openstack_networking_subnet_v2.private_subnet.id
  private_network_configuration {
      default_vrack_gateway              = ""
      private_network_routing_as_default = true
  }
}

resource "ovh_cloud_project_kube_iprestrictions" "bastion_only" {
  kube_id      = ovh_cloud_project_kube.cluster.id
  ips          = ["${openstack_compute_instance_v2.bastion.network[0].fixed_ip_v4}/32"]

  # We cannot add ip restrictions to Kube while all nodepools are not OK
  # OVH ticket CS10780553
  depends_on = [
    ovh_cloud_project_kube_nodepool.nodepool_access_csc,
    ovh_cloud_project_kube_nodepool.nodepool_infra,
    ovh_cloud_project_kube_nodepool.nodepool_prefect_flow,
    ovh_cloud_project_kube_nodepool.nodepool_processing,
    ovh_cloud_project_kube_nodepool.nodepool_processing_ondemand,
    ovh_cloud_project_kube_nodepool.nodepool_processing_systematic
  ]
}

resource "ovh_cloud_project_kube_nodepool" "nodepool_infra" {
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "infrastructure-${var.cluster_name}"
  flavor_name   = "b3-16"
  desired_nodes = var.nodepool_infra_desired_nodes
  min_nodes     = 0
  max_nodes     = 10
  autoscale     = var.nodepool_infra_autoscale
  template {
    metadata {
      annotations = {}
      labels = {
        "node-role.kubernetes.io/infra" = ""
      }
      finalizers = []
    }
    spec {
      unschedulable = false
      taints = []
    }
  }
}

resource "ovh_cloud_project_kube_nodepool" "nodepool_processing" {
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "processing-${var.cluster_name}"
  flavor_name   = "b3-16"
  desired_nodes = var.nodepool_processing_desired_nodes
  min_nodes     = 0
  max_nodes     = 5
  autoscale     = var.nodepool_processing_autoscale
  template {
    metadata {
      annotations = {}
      labels = {
        "node-role.kubernetes.io/processing" = ""
      }
      finalizers = []
    }
    spec {
      unschedulable = false
      taints = []
    }
  }
}

resource "ovh_cloud_project_kube_nodepool" "nodepool_access_csc" {
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "access-csc-${var.cluster_name}"
  flavor_name   = "b3-8"
  desired_nodes = var.nodepool_access_csc_desired_nodes
  min_nodes     = 0
  max_nodes     = 5
  autoscale     = var.nodepool_access_csc_autoscale
  template {
    metadata {
      annotations = {}
      labels = {
        "node-role.kubernetes.io/access_csc" = ""
      }
      finalizers = []
    }
    spec {
      unschedulable = false
      taints = [
        {
          effect = "NoSchedule"
          key    = "role"
          value  = "access_csc"
        }
      ]
    }
  }
}

resource "ovh_cloud_project_kube_nodepool" "nodepool_prefect_flow" {
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "prefect-flow-${var.cluster_name}"
  flavor_name   = "b3-16"
  desired_nodes = var.nodepool_prefect_desired_nodes
  min_nodes     = 0
  max_nodes     = 5
  autoscale     = var.nodepool_prefect_autoscale
  template {
    metadata {
      annotations = {}
      labels = {
        "node-role.kubernetes.io/prefect_flow" = ""
      }
      finalizers = []
    }
    spec {
      unschedulable = false
      taints = [
        {
          effect = "NoSchedule"
          key    = "role"
          value  = "prefect_flow"
        }
      ]
    }
  }
}

resource "ovh_cloud_project_kube_nodepool" "nodepool_processing_ondemand" {
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "processing-ondemand-${var.cluster_name}"
  flavor_name   = "b3-16"
  desired_nodes = var.nodepool_processing_ondemand_desired_nodes
  min_nodes     = 0
  max_nodes     = 5
  autoscale     = var.nodepool_processing_ondemand_autoscale
  template {
    metadata {
      annotations = {}
      labels = {
        "node-role.kubernetes.io/ondemand_dpr" = ""
      }
      finalizers = []
    }
    spec {
      unschedulable = false
      taints = [
        {
          effect = "NoSchedule"
          key    = "role"
          value  = "ondemand_dpr"
        }
      ]
    }
  }
}

resource "ovh_cloud_project_kube_nodepool" "nodepool_processing_systematic" {
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "processing-systematic-${var.cluster_name}"
  flavor_name   = "b3-16"
  desired_nodes = var.nodepool_processing_systematic_desired_nodes
  min_nodes     = 0
  max_nodes     = 5
  autoscale     = var.nodepool_processing_systematic_autoscale
  template {
    metadata {
      annotations = {}
      labels = {
        "node-role.kubernetes.io/systematic_dpr" = ""
      }
      finalizers = []
    }
    spec {
      unschedulable = false
      taints = [
        {
          effect = "NoSchedule"
          key    = "role"
          value  = "systematic_dpr"
        }
      ]
    }
  }
}

# Output part

output "kubeconfig_file" {
  value     = ovh_cloud_project_kube.cluster.kubeconfig
  sensitive = true
}

output "service_name" {
  value     = ovh_cloud_project_kube.cluster.service_name
  sensitive = false
}