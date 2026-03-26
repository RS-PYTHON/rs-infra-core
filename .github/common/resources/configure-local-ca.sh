#!/usr/bin/env bash
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

# --- Usage check
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <sd1:ns1> [<sd2:ns2> ...]"
  exit 1
fi

# --- Directories
RESOURCES_DIR=".github/common/resources/test"
APPS="${APPS_DIR:-apps}"
APP_CLUSTER_ISSUER="$APPS/02-cluster-issuer"
APP_OAUTH2_PROXY="$APPS/oauth2-proxy"

INIT_CA=false
if [[ ! -f "${APP_CLUSTER_ISSUER}/local-ca-issuer.yaml" ]]; then
  INIT_CA=true
fi

# --- Generate CA issuer files if not previously done
if ${INIT_CA}; then
  # --- Generate a local CA
  echo "Generating local CA..."
  openssl req -x509 -newkey rsa:4096 -days 1 -nodes \
    -keyout local-ca.key -out local-ca.crt \
    -subj "/CN=local CA/O=rspy/OU=dev" 2> /dev/null

  # --- Create local-ca-configmap.yaml
  echo "Creating ConfigMap..."
  while IFS= read -r line || [ -n "$line" ]; do
    printf '    %s\n' "${line}" >> "${RESOURCES_DIR}/local-ca-configmap.yaml"
  done < local-ca.crt

  # --- Create local-ca-secret.yaml with inlined base64 data
  echo "Creating Secret..."
  sed -i \
    -e "s!<crt>!$(base64 -w0 local-ca.crt)!g" \
    -e "s!<key>!$(base64 -w0 local-ca.key)!g" \
    "${RESOURCES_DIR}/local-ca-secret.yaml"

  # --- Cleanup
  rm -f local-ca.crt local-ca.key

  # --- Copy CA issuer files
  echo "Copying issuer files..."
  cp "${RESOURCES_DIR}/local-ca-secret.yaml" \
    "${RESOURCES_DIR}/local-ca-issuer.yaml" \
    "${APP_CLUSTER_ISSUER}/"
fi

# --- Handle all <sd>:<ns> pairs
CERT_FILES=""
for arg in "$@"; do
  sd="${arg%%:*}"
  ns="${arg##*:}"

  echo "Processing subdomain: $sd (namespace: $ns)"
  sed \
    -e "s!<sd>!$sd!g" \
    -e "s!<ns>!$ns!g" \
    "$RESOURCES_DIR/certificate.yaml" \
    > "$APP_CLUSTER_ISSUER/certificate-$sd.yaml"
  CERT_FILES="${CERT_FILES}\\n- certificate-${sd}.yaml"
done

# --- Update kustomization.yaml
echo "Updating kustomization.yaml..."

add_if_missing() {
  if ! grep -qxF -- "$1" "${APP_CLUSTER_ISSUER}/kustomization.yaml"; then
    sed -i "/- clusterIssuer.yaml/a\\
$1
" "${APP_CLUSTER_ISSUER}/kustomization.yaml"
  fi
}

add_if_missing "- local-ca-secret.yaml"
add_if_missing "- local-ca-issuer.yaml"

for arg in "$@"; do
  sd="${arg%%:*}"
  add_if_missing "- certificate-${sd}.yaml"
done

# --- Trust local CA in oauth2-proxy if not already done
if ${INIT_CA}; then
  echo "Adding local CA trust to oauth2-proxy..."
  sed 's!<ns>!iam!g' \
    "${RESOURCES_DIR}/local-ca-configmap.yaml" \
    > "${APP_OAUTH2_PROXY}/local-ca-configmap.yaml"
  echo -e "resources:\n- local-ca-configmap.yaml\n" | tee -a "${APP_OAUTH2_PROXY}/kustomization.yaml" > /dev/null
  cat <<'EOF' | tee -a "${APP_OAUTH2_PROXY}/values.yaml" > /dev/null
extraVolumes:
  - name: local-ca
    configMap:
      name: local-ca-configmap
extraVolumeMounts:
  - name: local-ca
    mountPath: /etc/ssl/certs/local-ca
    readOnly: true
EOF
fi

echo "✅ Done!"
