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

resource "random_string" "registry_username" {
  length  = 8
  upper   = false
  special = false
}

data "ovh_cloud_project_capabilities_containerregistry_filter" "capabilities" {
  plan_name    = "MEDIUM"
  region       = "GRA"
}

resource "ovh_cloud_project_containerregistry" "myregistry" {
  service_name = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.service_name
  plan_id      = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.id
  region       = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.region
  name         = "registry-${var.cluster_name}"
}

resource "ovh_cloud_project_containerregistry_user" "myuser" {
  service_name = ovh_cloud_project_containerregistry.myregistry.service_name
  registry_id  = ovh_cloud_project_containerregistry.myregistry.id
  email        = "${random_string.registry_username.result}@${replace(ovh_cloud_project_containerregistry.myregistry.url, "https://", "")}"
  login        = random_string.registry_username.result
}
