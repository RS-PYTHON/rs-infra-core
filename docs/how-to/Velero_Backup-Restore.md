# Velero Backup and Restore

## 1. Labelizing resources

All resources of componant to backup should be lablized. For example, regarding `Grafana` application, resources labelized with `velero=grafana-backup`.

```bash
kubectl -n monitoring label grafana.grafana.integreatly.org/grafana replicaset/grafana-deployment-XYZ pvc/grafana-pvc pv/pvc-XYZ serviceaccount/grafana-sa configmaps/grafana-ini  configmaps/grafana-plugins secrets/grafana-admin-credentials secrets/grafana-credentials services/grafana-service ingress/grafana-ingress servicemonitor/grafana pod/grafana-deployment-6598b4f597-p6ncb velero=grafana-backup
```

## 2. Backup

### 2.1 Create Backup manifest

Backup should be created through a manifest. In this example for `Grafana` application manifest file `velero-backup-grafana.yaml` (adapt content to the needs).

```yaml
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: backup-app-grafana
  namespace: infra
spec:
  includedNamespaces:
    - monitoring
  includedResources:
    - '*'
  volumeSnapshotLocations:
    - aws-default  
  labelSelector:
    matchLabels:
      velero: grafana-backup
  storageLocation: rs-velero-bucket-name
  snapshotVolumes: true
  ttl: 72h
```

### 2.2 Create Backup

Apply the manifest to create the backup itself.

```bash
kubectl -n infra apply -f velero-backup-grafana.yaml
```

### 2.3 Check Backup status

```bash
kubectl -n infra describe backup.velero backup-app-grafana
```

## 3. Delete resources

```bash
kubectl -n monitoring delete grafana.grafana.integreatly.org/grafana replicaset/grafana-deployment-XYZ pvc/grafana-pvc pv/pvc-XYZ serviceaccount/grafana-sa configmaps/grafana-ini  configmaps/grafana-plugins secrets/grafana-admin-credentials secrets/grafana-credentials services/grafana-service ingress/grafana-ingress servicemonitor/grafana pod/grafana-deployment-6598b4f597-p6ncb velero=grafana-backup
```

## 4. Restore

### 4.1 Create Restore manifest

Restore should be created through a manifest. In this example for `Grafana` application manifest file `velero-restore-grafana.yaml` (adapt content to the needs).

```yaml
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: restore-app-grafana
  namespace: infra
spec:
  backupName: backup-app-grafana
  includedNamespaces:
    - monitoring
  excludedResources:
    - volumesnapshotcontents.snapshot.storage.k8s.io
  restorePVs: true
```

### 4.2 Create Restore

Apply the manifest to create the backup itself.

```bash
kubectl -n infra apply -f velero-restore-grafana.yaml
```

### 4.3 Check Restore status

```bash
kubectl -n infra describe restore.velero restore-app-grafana
```
