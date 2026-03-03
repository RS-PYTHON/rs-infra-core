# Restore database with CloudNativePG

## Important notes

You can only restore a whole cluster with CloudNativePG, not just one database.

## PostgreSQL cluster (non pgstac)

From the YAML below, edit the fields:

- `{{ postgresql.bucket }}`
- `{{ s3.endpoint }}`

And apply it with `kubectl -n database apply -f <input_file.yaml>`.

```YAML
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

## pgstac cluster

Use this manifest to create a new pgstac cluster named `pgstac-cluster-recovery` that will bootstrap from an existing backup of the pgstac cluster named `pgstac-cluster`, using the `barmanObject` named `pgstac`.

You need to change the value of `backupID` according to your backup. You can retrieve that ID from the backup Kubernetes object you want to restore, for e.g. :

```Shell
kubectl -n database get backup backup-pgstac-cluster-20260225110000 -o=jsonpath='{.status.backupId}'`
```

Manifest :

```YAML
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

apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: pgstac-cluster-recovery
  labels:
    app.kubernetes.io/instance: '{{ app_name }}'
    wait-for-deployment: Ready
spec:
  instances: 1

  enableSuperuserAccess: true

  imageCatalogRef:
    apiGroup: postgresql.cnpg.io
    kind: ClusterImageCatalog
    name: postgis-standard-trixie
    major: 18

  bootstrap:
    recovery:
      source: pgstac-cluster
      recoveryTarget:
        backupID: 20260225T110002 #CHANGEME
        targetImmediate: true

  externalClusters:
    - name: pgstac-cluster
      plugin:
        name: barman-cloud.cloudnative-pg.io
        parameters:
          barmanObjectName: pgstac
          serverName: pgstac-cluster

  storage:
    pvcTemplate:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 8Gi
      storageClassName: csi-cinder-high-speed-retain
      volumeMode: Filesystem

  resources:
    requests:
      memory: "256Mi"
      cpu: 100m
    limits:
      memory: "1024Mi"
      cpu: 300m

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
            - key: "node-role.kubernetes.io/rs_server"
              operator: Exists
    tolerations:
      - effect: NoSchedule
        key: role
        value: rs_server
```