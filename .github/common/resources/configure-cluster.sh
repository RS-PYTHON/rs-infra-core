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

# --- Usage ---
# ./configure-cluster.sh "<labels>" "<subdomains>"
# Example :
# ./configure-cluster.sh "node-role.kubernetes.io/infra= node-role.kubernetes.io/rs_env=" "iam kube oauth2-proxy"

LABELS_INPUT="${1:-}"
SUBDOMAINS_INPUT="${2:-}"

if [[ -z "$LABELS_INPUT" || -z "$SUBDOMAINS_INPUT" ]]; then
  echo "❌ Usage: $0 \"<labels>\" \"<subdomains>\""
  echo "Example: $0 \"node-role.kubernetes.io/infra= node-role.kubernetes.io/rs_env=\" \"iam kube oauth2-proxy\""
  exit 1
fi

# --- Convert inputs to arrays ---
read -r -a SUBDOMAINS <<< "$SUBDOMAINS_INPUT"

# --- Label the minikube node ---
echo "🏷️  Applying labels to node 'minikube': $LABELS_INPUT"
read -r -a LABELS <<< "$LABELS_INPUT"
kubectl label node minikube "${LABELS[@]}"

# --- Extract domain and IP
DOMAIN=$(yq e '.platform_domain_name' ./inventory/sample/host_vars/setup/main.yaml)
MINIKUBE_IP=$(minikube ip)
FIXED_IP="192.168.49.240"

echo "🌐 Using domain: $DOMAIN"
echo "💡 Minikube IP: $MINIKUBE_IP"

# --- Ensure runner (GitHub host) can resolve app domains
echo "🧩 Updating /etc/hosts..."
for sd in "${SUBDOMAINS[@]}" ; do
  echo "$FIXED_IP $sd.$DOMAIN" | sudo tee -a /etc/hosts
done

# --- Validate /etc/hosts resolution on the runner
echo "🔍 Verifying host DNS resolution..."
for sd in "${SUBDOMAINS[@]}" ; do
  if dig +short "$sd.$DOMAIN" > /dev/null; then
    echo "✅ $sd.$DOMAIN resolves on host"
  else
    echo "❌ Host DNS failed for $sd.$DOMAIN"
    exit 2
  fi
done
echo "✅ Host DNS resolution works"

# --- Create MetalLB configmap to define fixed IP address range
echo "⚙️ Applying MetalLB config..."
kubectl apply -f .github/common/resources/test/metallb-configmap.yaml

# --- Fetch current CoreDNS config
echo "🧠 Patching CoreDNS..."
kubectl -n kube-system get configmap coredns -o yaml > coredns-configmap.yaml
# --- Build hosts entries from SUBDOMAINS
HOSTS_BLOCK=""
for sd in "${SUBDOMAINS[@]}"; do
    HOSTS_BLOCK+="           $FIXED_IP ${sd}.${DOMAIN}\n"
done
# --- Inject hosts into coredns config map
awk -v block="$HOSTS_BLOCK" '/192\.168\.49\.1/{printf "%s", block; ok=1} {print} END{exit ok?0:1}' \
  coredns-configmap.yaml > coredns-configmap.yaml.patched.yaml || {
  echo "❌ awk did not replace anything";
  exit 3;
}
# --- Patch CoreDNS and restart
kubectl -n kube-system patch configmap coredns --type merge -p "$(cat coredns-configmap.yaml.patched.yaml)"
kubectl -n kube-system rollout restart deployment coredns

# --- Wait for CoreDNS to be ready
kubectl -n kube-system rollout status deployment coredns --timeout=60s
# --- Create a temporary debug pod to verify DNS from inside cluster
kubectl run dns-test --image=busybox:latest --restart=Never -- sleep 30 &
sleep 1
kubectl wait --for=condition=Ready pod/dns-test --timeout=30s || (echo "❌ dns-test pod not ready" && exit 4)

# --- Verify DNS resolution inside the cluster
echo "🔬 Testing DNS resolution inside the cluster..."
for sd in "${SUBDOMAINS[@]}"; do
  echo "🔍 Checking DNS for $sd.$DOMAIN..."
  RESOLVED_IP=$(kubectl exec dns-test -- nslookup "$sd.$DOMAIN" 2>/dev/null | awk '/^Address: /{print $2; exit}')
  if [[ "$RESOLVED_IP" == "$FIXED_IP" ]]; then
    echo "✅ $sd.$DOMAIN resolves correctly to $RESOLVED_IP"
  else
    echo "❌ DNS resolution failed for $sd.$DOMAIN (expected $FIXED_IP, got ${RESOLVED_IP:-none})"
    exit 5
  fi
done
echo "✅ DNS resolution works correctly inside the cluster"
# Clean up debug pod
kubectl delete pod dns-test --ignore-not-found=true --grace-period=0 --force
