#!/bin/bash
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

set -euo pipefail

# Deploy rancher local-path-provisioner manually rather than through minikube addon to avoid race condition with default-storageclass
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.34/deploy/local-path-storage.yaml

# Deploy rustfs
helm repo add rustfs https://charts.rustfs.com/
helm repo update rustfs
helm install rustfs rustfs/rustfs --namespace rustfs \
  --set mode.standalone.enabled="true" \
  --set mode.distributed.enabled="false" \
  --set replicaCount=1 \
  --set secret.rustfs.access_key=s3_access_key \
  --set secret.rustfs.secret_key=s3_secret_key \
  --set buckets[0].name=rs-cluster-psql,buckets[1].name=rs-cluster-velero \
  --set ingress.hosts[0].host=rspy.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix \
  --create-namespace --wait
