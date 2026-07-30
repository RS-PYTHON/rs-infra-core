#!/bin/bash
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

set -euo pipefail

APPS="${APPS_DIR:-apps}"

# protect jinja templating
sed -i \
  's|{{ ingress.annotations }}|"__HELM_PLACEHOLDER_INGRESS_ANNOTATIONS__"|' \
  "${APPS}/03-ingress-nginx/values.yaml"

yq -i \
  '.controller.service.annotations."metallb.universe.tf/address-pool" = "nginx"' \
  "${APPS}/03-ingress-nginx/values.yaml"

# restore jinja templating
sed -i \
  's|"__HELM_PLACEHOLDER_INGRESS_ANNOTATIONS__"|{{ ingress.annotations }}|' \
  "${APPS}/03-ingress-nginx/values.yaml"
