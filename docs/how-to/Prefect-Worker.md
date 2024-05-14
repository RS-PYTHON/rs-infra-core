# Prefect Worker Workpoool concurrency-limits


##  1. Open shell to the running container `prefect-server`

```bash
kubectl -n processing exec -it prefect-server-abc456  -- /bin/bash
```

##  2. Check `Concurrency Limit` on workpool _on-demand-k8s-pool_

```bash
 prefect work-pool ls
```
| Name               | Type          | ID               |Concurrency Limit |
| ------------------ |:-------------:|:----------------:|:----------------:|
| on-demand-k8s-pool |kubernetes     | xyz123-xyz123-...|`None`            |       



##  3. Set `Concurrency Limit` on workpool _on-demand-k8s-pool_

```bash
prefect work-pool set-concurrency-limit on-demand-k8s-pool 10
```

> Return command on prompt should be : **_Set concurrency limit for work pool 'on-demand-k8s-pool' to 10_**

```bash
 prefect work-pool ls
```
| Name               | Type          | ID               |Concurrency Limit |
| ------------------ |:-------------:|:----------------:|:----------------:|
| on-demand-k8s-pool |kubernetes     | xyz123-xyz123-...|`10`            |      

*Setting should be check into WebUI too, on parameters page of workpool _on-demand-k8s-pool_ .*



