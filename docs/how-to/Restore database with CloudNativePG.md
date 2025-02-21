# Restore database with CloudNativePG

From the YAML below, edit the fields:

- `{{ postgresql.bucket }}`
- `{{ s3.endpoint }}`

And apply it with `kubectl -n database apply -f <input_file.yaml>`.

```YAML
# Copyright 2024 CS Group
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

apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: psql-restore
spec:
  backup:
    barmanObjectStore:
      destinationPath: s3://{{ postgresql.bucket }}/recovered-postgresql-cluster/
      endpointURL: {{ s3.endpoint }}
      serverName: "recoveredCluster"
      s3Credentials:
        accessKeyId:
          key: AK
          name: psql-backup-obs
        secretAccessKey:
          key: SK
          name: psql-backup-obs
    retentionPolicy: "10d"

  bootstrap:
    recovery:
      source: clusterBackup

  externalClusters:
    - name: clusterBackup
      barmanObjectStore:
        destinationPath: s3://{{ postgresql.bucket }}/postgresql-cluster/
        endpointURL: {{ s3.endpoint }}
        s3Credentials:
          accessKeyId:
            key: AK
            name: psql-backup-obs
          secretAccessKey:
            key: SK
            name: psql-backup-obs

  instances: 3
  
  enableSuperuserAccess: true

  postgresql:
    parameters:
      shared_buffers: "256MB"

  resources:
    requests:
      memory: "256Mi"
      cpu: 100m
    limits:
      memory: "1024Mi"
      cpu: 300m

  storage:
    storageClass: csi-cinder-high-speed-retain
    size: 30Gi

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
            - key: "node-role.kubernetes.io/infra"
              operator: Exists
  monitoring:
    enablePodMonitor: true
```

It will create a new CloudNativePG cluster **from** the backup defined from the field `spec.externalClusters.barmanObjectStore.destinationPath`.

And backup the **new** cluster in the path defined from the field `spec.backup.barmanObjectStore.destinationPath`.
