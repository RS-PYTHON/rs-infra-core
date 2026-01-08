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

echo "=== 🧭 Cluster info ==="
kubectl cluster-info || true
kubectl get nodes -o wide || true

echo ""
echo "=== ⚙️ Node resource details ==="
kubectl describe node minikube | grep -E "cpu|memory|Allocatable|Capacity" || true

echo ""
echo "=== 📊 Resource usage (requires metrics-server) ==="
kubectl top nodes || echo "metrics-server not available"
kubectl top pods -A || echo "metrics-server not available"

echo ""
echo "=== 📦 Pods ==="
kubectl get pods -A -o wide

echo ""
echo "=== 🌐 Services ==="
kubectl get svc -A

echo ""
echo "=== 🔀 Ingresses ==="
kubectl get ingresses -A

echo ""
echo "=== 🔗 EndpointSlices ==="
kubectl get endpointslices -A

echo ""
echo "=== 🧱 Deployments ==="
kubectl get deployments -A

echo ""
echo "=== ⚙️ ReplicaSets ==="
kubectl get rs -A

echo ""
echo "=== 🔑 Secrets ==="
kubectl get secrets -A

echo ""
echo "=== 🪪 Service Accounts ==="
kubectl get sa -A

echo ""
echo "=== 🧩 Custom Resource Definitions ==="
kubectl get crd -A

echo ""
echo "=== ⚠️ Events (sorted by time) ==="
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -n 50

echo ""
echo "=== 🔬 Pods resource requests/limits ==="
kubectl get pods -A -o custom-columns=NAMESPACE:.metadata.namespace,POD:.metadata.name,CPU_REQ:.spec.containers[*].resources.requests.cpu,CPU_LIM:.spec.containers[*].resources.limits.cpu,MEM_REQ:.spec.containers[*].resources.requests.memory,MEM_LIM:.spec.containers[*].resources.limits.memory

echo ""
echo "=== 📄 Failed or Pending pod logs (last 100 lines) ==="
kubectl get pods -A -o json \
| jq -r '
    .items[]
    | select(
        .status.phase != "Running"
        or ([.status.containerStatuses[]?.restartCount] | add // 0) > 0
      )
    | "\(.metadata.namespace) \(.metadata.name)"
' |
while read -r ns pod; do
if [[ "$pod" =~ (create|patch) ]]; then
    echo "--- Skipping ephemeral pod $ns/$pod ---"
    continue
fi

echo ""
echo "--- Logs for $ns/$pod (current) ---"
kubectl logs -n "$ns" "$pod" --all-containers --tail=100 2>/dev/null || \
    echo "⚠️ No current logs available, trying previous logs..."
echo ""
echo "--- Logs for $ns/$pod (previous) ---"
kubectl logs -n "$ns" "$pod" --all-containers --previous --tail=100 2>/dev/null || \
    echo "⚠️ No previous logs available"
done

echo ""
echo "=== ✅ Diagnostic complete ==="
