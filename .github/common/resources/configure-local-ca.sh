#!/usr/bin/env bash
set -euo pipefail

# --- Usage check
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <sd1:ns1> [<sd2:ns2> ...]"
  exit 1
fi

# --- Directories
RESOURCES_DIR=".github/common/resources/test"
APP_CLUSTER_ISSUER="apps/02-cluster-issuer"
APP_OAUTH2_PROXY="apps/oauth2-proxy"

# --- Generate a local CA
echo "Generating local CA..."
openssl req -x509 -newkey rsa:4096 -days 1 -nodes \
  -keyout local-ca.key -out local-ca.crt \
  -subj "/CN=local CA/O=rspy/OU=dev" 2> /dev/null

# --- Create local-ca-configmap.yaml
echo "Creating ConfigMap..."
while IFS= read -r line || [ -n "$line" ]; do
  printf '    %s\n' "$line" >> "$RESOURCES_DIR/local-ca-configmap.yaml"
done < local-ca.crt

# --- Create local-ca-secret.yaml with inlined base64 data
echo "Creating Secret..."
sed -i \
  -e "s!<crt>!$(base64 -w0 local-ca.crt)!g" \
  -e "s!<key>!$(base64 -w0 local-ca.key)!g" \
  "$RESOURCES_DIR/local-ca-secret.yaml"

# --- Cleanup
rm -f local-ca.crt local-ca.key

# --- Copy CA issuer files
echo "Copying issuer files..."
cp "$RESOURCES_DIR/local-ca-secret.yaml" \
   "$RESOURCES_DIR/local-ca-issuer.yaml" \
   "$APP_CLUSTER_ISSUER/"

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
sed -i "/- clusterIssuer.yaml/a\- local-ca-secret.yaml\\n- local-ca-issuer.yaml$CERT_FILES" "$APP_CLUSTER_ISSUER/kustomization.yaml"

# --- Trust local CA in oauth2-proxy
echo "Adding local CA trust to oauth2-proxy..."
sed 's!<ns>!iam!g' \
  "$RESOURCES_DIR/local-ca-configmap.yaml" \
  > "$APP_OAUTH2_PROXY/local-ca-configmap.yaml"
echo -e "resources:\n- local-ca-configmap.yaml\n" | tee -a $APP_OAUTH2_PROXY/kustomization.yaml > /dev/null
cat <<'EOF' | tee -a $APP_OAUTH2_PROXY/values.yaml > /dev/null
extraVolumes:
  - name: local-ca
    configMap:
      name: local-ca-configmap
extraVolumeMounts:
  - name: local-ca
    mountPath: /etc/ssl/certs/local-ca
    readOnly: true
EOF

echo "✅ Done!"
