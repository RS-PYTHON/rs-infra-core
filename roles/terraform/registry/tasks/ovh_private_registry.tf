data "ovh_cloud_project_capabilities_containerregistry_filter" "capabilities" {
  plan_name    = "SMALL"
  region       = "GRA"
}

resource "ovh_cloud_project_containerregistry" "myregistry" {
  plan_id      = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.id
  region       = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.region
  name         = "registry-${var.cluster_name}"
}

resource "ovh_cloud_project_containerregistry_user" "myuser" {
    registry_id  = ovh_cloud_project_containerregistry.myregistry.id
    email        = "my.user@mycompany.com"
    login        = "admin"
}