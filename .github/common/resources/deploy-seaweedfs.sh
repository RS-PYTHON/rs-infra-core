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

# Arguments
BUCKETS_ARG="${1:-}"
TEST_DIR="${2:-.github/common/resources/test}"

HELM_BUCKET_ARGS=()

if [[ -n "${BUCKETS_ARG}" ]]; then
  IFS=',' read -ra BUCKETS <<< "${BUCKETS_ARG}"

  idx=0
  for bucket in "${BUCKETS[@]}"; do
    HELM_BUCKET_ARGS+=(
      --set "filer.s3.createBuckets[${idx}].name=${bucket}"
      --set "filer.s3.createBuckets[${idx}].anonymousRead=true"
    )
    ((++idx))
  done
fi

echo "Deploying seaweedfs with buckets:"
printf '  %q\n' "${HELM_BUCKET_ARGS[@]}"

# Deploy seaweedfs
helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update seaweedfs
kubectl create namespace seaweedfs
kubectl apply -f "${TEST_DIR}/seaweedfs-s3-secret.yaml"
helm install seaweedfs seaweedfs/seaweedfs --namespace seaweedfs --wait --timeout=180s \
  --version 4.0.406 \
  --set master.affinity="" \
  --set filer.affinity="" \
  --set volume.affinity="" \
  --set filer.s3.port=9000 \
  --set filer.s3.enabled="true" \
  --set filer.s3.enableAuth="true" \
  --set filer.s3.existingConfigSecret=seaweedfs-s3-secret \
  "${HELM_BUCKET_ARGS[@]}"
kubectl port-forward -n seaweedfs svc/seaweedfs-s3 9000:9000 &

echo "Loading S3 credentials from Kubernetes secret seaweedfs/seaweedfs-s3-secret..."
s3_config_json=$(kubectl get secret seaweedfs-s3-secret -n seaweedfs -o jsonpath='{.data.seaweedfs_s3_config}' | base64 --decode)

if [[ -z "${s3_config_json}" ]]; then
  echo "ERROR: Unable to read seaweedfs_s3_config from secret"
  exit 1
fi

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

AWS_ACCESS_KEY_ID=$(jq -r '.identities[0].credentials[0].accessKey' <<< "${s3_config_json}")
AWS_SECRET_ACCESS_KEY=$(jq -r '.identities[0].credentials[0].secretKey' <<< "${s3_config_json}")

if [[ -z "${AWS_ACCESS_KEY_ID}" || -z "${AWS_SECRET_ACCESS_KEY}" || "${AWS_ACCESS_KEY_ID}" == "null" ]]; then
  echo "ERROR: Failed to extract AWS credentials from secret"
  exit 2
fi

echo "Checking buckets with aws s3api..."

for attempt in {1..20}; do
  if buckets=$(aws s3api list-buckets \
    --endpoint-url http://127.0.0.1:9000 \
    --query 'Buckets[].Name' \
    --output text 2>/dev/null); then
    break
  fi
  echo "Waiting for SeaweedFS S3 to be ready... (${attempt}/20)"
  sleep 1
done

if [[ -z "${buckets:-}" ]]; then
  echo "ERROR: Unable to list buckets via aws s3api"
  aws s3api list-buckets --endpoint-url http://127.0.0.1:9000
  exit 3
fi

for bucket in "${BUCKETS[@]}"; do
  if ! grep -qw "${bucket}" <<< "${buckets}"; then
    echo "ERROR: Bucket '${bucket}' not found"
    exit 4
  fi
  echo "Bucket '${bucket}' OK"
done
