#!/bin/bash
# Copyright 2025 CS Group
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

set -euo pipefail

APPS="${APPS_DIR:-apps}"

# Lower the CPU and memory requests
sed -i -e 's!cpu: 300m!cpu: 10m!g' -e 's!memory: 400Mi!memory: 50Mi!g' "${APPS}/03-keycloak-operator/deployment.yaml"

# Allow retrieving of oidc tokens for all clients with login+password to ease tests
sed -i 's!directAccessGrantsEnabled: false!directAccessGrantsEnabled: true!g' "${APPS}/05-keycloak/keycloakrealmimport.yaml"
