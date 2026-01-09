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

# Arguments
BUCKETS_ARG="${1:-}"
TEST_DIR="${2:-.github/common/resources/test}"

HELM_BUCKET_ARGS=()

if [[ -n "${BUCKETS_ARG}" ]]; then
  IFS=',' read -ra BUCKETS <<< "${BUCKETS_ARG}"

  idx=0
  for bucket in "${BUCKETS[@]}"; do
    HELM_BUCKET_ARGS+=(
      --set "s3.createBuckets[${idx}].name=${bucket}"
      --set "s3.createBuckets[${idx}].anonymousRead=true"
    )
    ((++idx))
  done
fi

echo "Deploying seaweedfs with buckets:"
printf '  %q\n' "${HELM_BUCKET_ARGS[@]}"

# Deploy seaweedfs
# TODO remove the hardcoded 4.0.4 version after 4.0.6 is released (4.0.5 is buggy)
helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update seaweedfs
kubectl create namespace seaweedfs
kubectl apply -f "${TEST_DIR}/seaweedfs-s3-secret.yaml"
helm install seaweedfs seaweedfs/seaweedfs --namespace seaweedfs --wait --timeout=180s \
  --version 4.0.404 \
  --set master.affinity="" \
  --set filer.affinity="" \
  --set volume.affinity="" \
  --set filer.s3.enabled="true" \
  --set filer.s3.enableAuth="true" \
  --set filer.s3.existingConfigSecret=seaweedfs-s3-secret \
  "${HELM_BUCKET_ARGS[@]}"
