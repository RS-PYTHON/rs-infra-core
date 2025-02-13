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
  ips          = ["${openstack_compute_instance_v2.bastion.network[1].fixed_ip_v4}/32"]
}

resource "ovh_cloud_project_kube_nodepool" "nodepool_infra" {
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "infrastructure-${var.cluster_name}"
  flavor_name   = "b3-16"
  desired_nodes = var.nodepool_infra_desired_nodes
  min_nodes     = 0
  max_nodes     = 10
  autoscale     = true
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
      taints = [
        {
          effect = "NoSchedule"
          key    = "role"
          value  = "infra"
        }
      ]
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
  autoscale     = true
  template {
    metadata {
      labels = {
        "node-role.kubernetes.io/processing" = ""
      }
    }
    spec {
      unschedulable = false
      taints = [
        {
          effect = "PreferNoSchedule"
          key    = "role"
          value  = "processing"
        }
      ]
    }
  }
}

resource "ovh_cloud_project_kube_nodepool" "nodepool_access_csc" {
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "access-csc-${var.cluster_name}"
  flavor_name   = "b3-16"
  desired_nodes = var.nodepool_access_csc_desired_nodes
  min_nodes     = 0
  max_nodes     = 5
  autoscale     = true
  template {
    metadata {
      labels = {
        "node-role.kubernetes.io/access_csc" = ""
      }
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
  autoscale     = true
  template {
    metadata {
      labels = {
        "node-role.kubernetes.io/prefect_flow" = ""
      }
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
  service_name  = "${var.service_name}"
  name          = "processing-ondemand-${var.cluster_name}"
  flavor_name   = "b3-16"
  desired_nodes = var.nodepool_processing_ondemand_desired_nodes
  min_nodes     = 0
  max_nodes     = 5
  autoscale     = true
  template {
    metadata {
      labels = {
        "node-role.kubernetes.io/ondemand_dpr" = ""
      }
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
  autoscale     = true
  template {
    metadata {
      labels = {
        "node-role.kubernetes.io/systematic_dpr" = ""
      }
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