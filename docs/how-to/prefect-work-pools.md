# Prefect work pools concurrency limit

The Prefect work pools of RS-Python (`processing-integrated-k8s-pool`, `processing-sandbox-k8s-pool`,
`monitoring-k8s-pool`) are created by [rs-workflow-env](https://github.com/RS-PYTHON/rs-workflow-env). The
[concurrency limit](https://docs.prefect.io/v3/concepts/work-pools#work-pool-concurrency) of a work pool is the
maximum number of flow runs that can run at the same time in this work pool. The other flow runs wait in the
`Pending` state. By default, there is no limit.

## 1. Open a shell in the Prefect server container

```bash
kubectl -n processing get pods -l app.kubernetes.io/name=prefect-server
kubectl -n processing exec -it <prefect-server-pod> -- /bin/bash
```

## 2. Check the concurrency limit of the work pools

```bash
prefect work-pool ls
```

| Name | Type | ID | Concurrency Limit |
|---|---|---|---|
| processing-integrated-k8s-pool | kubernetes | xyz123-xyz123-... | `None` |

## 3. Set the concurrency limit of a work pool

```bash
prefect work-pool set-concurrency-limit processing-integrated-k8s-pool 10
```

The command returns: `Set concurrency limit for work pool 'processing-integrated-k8s-pool' to 10`.

```bash
prefect work-pool ls
```

| Name | Type | ID | Concurrency Limit |
|---|---|---|---|
| processing-integrated-k8s-pool | kubernetes | xyz123-xyz123-... | `10` |

The limit is also displayed, and can be changed, in the *Work Pools* page of the Prefect web interface.
