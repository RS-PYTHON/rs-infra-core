# Prefect Worker Workpoool concurrency-limits


##  1. Check `Concurrency Limit` on workpool _on-demand-k8s-pool_


```
 prefect work-pool ls
```


| Name               | Type          | ID               |Concurrency Limit |
| ------------------ |:-------------:|:----------------:|:----------------:|
| on-demand-k8s-pool |kubernetes     | xyz123-xyz123-...|`None`            |       



> Return command on prompt should be : **_Set concurrency limit for work pool 'on-demand-k8s-pool' to 10_**


##  2. set `Concurrency Limit` on workpool _on-demand-k8s-pool_

```
prefect work-pool set-concurrency-limit on-demand-k8s-pool 10
```

| Name               | Type          | ID               |Concurrency Limit |
| ------------------ |:-------------:|:----------------:|:----------------:|
| on-demand-k8s-pool |kubernetes     | xyz123-xyz123-...|`10`            |      



*Setting should be check into WebUI too on parameters page of workpool _on-demand-k8s-pool_ .*

 




