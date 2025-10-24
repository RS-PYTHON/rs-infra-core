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

cp -rfp inventory/sample inventory/mycluster
mv inventory/mycluster/.env.template inventory/mycluster/.env
mv inventory/mycluster/openrc.sh.template inventory/mycluster/openrc.sh
sed -i 's!<changeme_with_full_path>/miniforge3/envs/rspy!/usr/share/miniconda/envs/rspy!g' inventory/mycluster/hosts.yaml
# --- Use minio as S3 provider and local CA issuer instead of Let's Encrypt
sed -i\
    -e 's!https://s3.gra.io.cloud.ovh.net!http://minio.minio.svc.cluster.local:9000!'\
    -e 's!letsencrypt-prod!local-ca-issuer!g'\
    inventory/mycluster/host_vars/setup/main.yaml
# --- Configure minikube storage class provisioner, ingress-nginx LoadBalancer to retrieve fixed IP address from metalLB, oauth2-proxy to trust local-ca
sed -i \
    -e 's!cinder.csi.openstack.org!k8s.io/minikube-hostpath!g'\
    -e 's!instances: 3!instances: 1!g'\
    -e 's!number: 2!number: 1!g'\
    -e 's!annotations: {}!annotations:\n    metallb.universe.tf/address-pool: default!g'\
    -e 's!provider_ca_files: ""!provider_ca_files: "/etc/ssl/certs/local-ca/tls.crt"!g'\
    inventory/mycluster/host_vars/setup/apps.yml
