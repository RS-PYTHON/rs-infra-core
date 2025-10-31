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
echo "=== 🧩 Pod summary ==="
kubectl get pods -A -o wide

echo ""
echo "=== 🧱 Deployments and ReplicaSets ==="
kubectl get deployments -A
kubectl get rs -A

echo ""
echo "=== ⚠️ Events (sorted by time) ==="
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -n 50

echo ""
echo "=== 🔬 Pods resource requests/limits ==="
kubectl get pods -A -o custom-columns=NAMESPACE:.metadata.namespace,POD:.metadata.name,CPU_REQ:.spec.containers[*].resources.requests.cpu,CPU_LIM:.spec.containers[*].resources.limits.cpu,MEM_REQ:.spec.containers[*].resources.requests.memory,MEM_LIM:.spec.containers[*].resources.limits.memory

echo ""
echo "=== 📄 Failed or Pending pod logs (last 30 lines) ==="
kubectl get pods -A \
--field-selector=status.phase!=Running \
-o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' |
while read -r ns pod; do
if [[ "$pod" =~ (create|patch) ]]; then
    echo "--- Skipping ephemeral pod $ns/$pod ---"
    continue
fi

echo ""
echo "--- Logs for $ns/$pod ---"
if ! kubectl logs -n "$ns" "$pod" --all-containers --tail=30 2>/dev/null; then
    echo "⚠️ No current logs available, trying previous logs..."
    kubectl logs -n "$ns" "$pod" --all-containers --previous --tail=30 2>/dev/null || \
        echo "⚠️ No logs available (pod may have terminated)"
fi
done

echo ""
echo "=== ✅ Diagnostic complete ==="
