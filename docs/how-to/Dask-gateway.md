# Dask Gateway

## Prerequisite

Have a token generated from https://processing.{{ platform_domain_name }}/jupyter/hub/token and also set in the rs-server-staging configuration.

## Connect to the Gateway

``` Python
# Set up the environement and connect to the dask-gateway
os.environ["JUPYTERHUB_API_TOKEN"] = "<TOKEN_GENERATED_FROM_PREVIOUS_STEP>"

from dask_gateway import Gateway
gateway = Gateway(
     address="http://traefik-dask-gateway.dask-gateway.svc.cluster.local",
     auth="jupyterhub"
)
```

## Get the list of clusters

``` Python
gateway.list_clusters()
```

## Start cluster

### Create single Dask cluster (without option) (Option 1)

``` Python
cluster = gateway.new_cluster()
print (cluster.name)
```

### Create a basic Dask cluster with options (Option 2)

``` Python
# List of options available
options = gateway.cluster_options()

for key in options.keys():
    print(f"{key}: {options[key]}")

cluster = gateway.new_cluster(
    worker_cores=1,
    worker_memory=2.0,
    namespace='dask-gateway',
    image='ghcr.io/rs-python/rs-infra-core-dask-eopf:latest'
)

print (cluster.name)
gateway.scale_cluster(cluster.name, 3)
```

### Create a Dask cluster for staging with options (Option 3)

For the staging, we must configure the `cluster_name` field and the node affinity for the Dask scheduler and workers. We can also tune the CPU/RAM usage and limits :

``` Python
# List of options available
options = gateway.cluster_options()

for key in options.keys():
    print(f"{key}: {options[key]}")

cluster = gateway.new_cluster(
    namespace='dask-gateway',
    image='ghcr.io/rs-python/rs-infra-core-dask-staging:latest',
    cluster_name='dask-staging',
    scheduler_extra_pod_labels={'cluster_name': 'dask-staging'},
    worker_cores=1,
    worker_memory=2.0, # In GB
    cluster_max_workers=3,
    cluster_max_cores=3,
    cluster_max_memory=9663676416, # In Bytes
    worker_extra_pod_config={'affinity': {'nodeAffinity': {'requiredDuringSchedulingIgnoredDuringExecution': {'nodeSelectorTerms': [{'matchExpressions': [{'key': 'node-role.kubernetes.io/access_csc', 'operator': 'Exists'}]}]}}}, 'tolerations': [{'key': 'role', 'operator': 'Equal', 'value': 'access_csc', 'effect': 'NoSchedule'}]},
    scheduler_extra_pod_config={'affinity': {'nodeAffinity': {'requiredDuringSchedulingIgnoredDuringExecution': {'nodeSelectorTerms': [{'matchExpressions': [{'key': 'node-role.kubernetes.io/access_csc', 'operator': 'Exists'}]}]}}}, 'tolerations': [{'key': 'role', 'operator': 'Equal', 'value': 'access_csc', 'effect': 'NoSchedule'}]}
)

print (cluster.name)
gateway.scale_cluster(cluster.name, 2)
```

The calculations for `cluster_max_workers`, `cluster_max_cores`, `cluster_max_memory` are :

* `cluster_max_workers`: $`scale\_value + 1`$
* `cluster_max_cores`: $`(scale\_value + 1) * worker\_cores`$
* `cluster_max_memory`: $`(scale\_value + 1) * worker\_memory * 2^{30}`$

Where $`scale\_value`$ = maximum desired worker, 2 in the prevous example.

### Create a Dask cluster for DPR (option 4)

For the DPR processing, we must configure the `cluster_name` field and the node affinity for the Dask scheduler and workers. We must also tune the CPU/RAM usage and limits :

``` Python
# List of options available
options = gateway.cluster_options()

for key in options.keys():
    print(f"{key}: {options[key]}")

cluster = gateway.new_cluster(
    namespace='dask-gateway',
    image='ghcr.io/rs-python/rs-infra-core-dask-eopf:latest',
    cluster_name='dask-eopf',
    scheduler_extra_pod_labels={'cluster_name': 'dask-eopf'},
    worker_cores=1,
    worker_memory=2.0, # In GB
    cluster_max_workers=3,
    cluster_max_cores=3,
    cluster_max_memory=9663676416, # In Bytes
    scheduler_memory_limit=60, # In GB
    worker_extra_pod_config={'affinity': {'nodeAffinity': {'requiredDuringSchedulingIgnoredDuringExecution': {'nodeSelectorTerms': [{'matchExpressions': [{'key': 'node-role.kubernetes.io/dask_worker_on_demand', 'operator': 'Exists'}]}]}}}, 'tolerations': [{'key': 'role', 'operator': 'Equal', 'value': 'dask_worker_on_demand', 'effect': 'NoSchedule'}]},
    scheduler_extra_pod_config={'affinity': {'nodeAffinity': {'requiredDuringSchedulingIgnoredDuringExecution': {'nodeSelectorTerms': [{'matchExpressions': [{'key': 'node-role.kubernetes.io/dask_scheduler', 'operator': 'Exists'}]}]}}}, 'tolerations': [{'key': 'role', 'operator': 'Equal', 'value': 'dask_scheduler', 'effect': 'NoSchedule'}]}
)

print (cluster.name)
gateway.scale_cluster(cluster.name, 2)
```

The calculations for `cluster_max_workers`, `cluster_max_cores`, `cluster_max_memory` are :

* `cluster_max_workers`: $`scale\_value + 1`$
* `cluster_max_cores`: $`(scale\_value + 1) * worker\_cores`$
* `cluster_max_memory`: $`(scale\_value + 1) * worker\_memory * 2^{30}`$

Where $`scale\_value`$ = maximum desired worker, 2 in the prevous example.

### Shutdown all the dask clusters

``` Python
clusters = gateway.list_clusters()

# Shutting down all clusters
for cluster_info in clusters:
    try:
        cluster = gateway.connect(cluster_info.name)
        cluster.shutdown()
        print(f"Cluster {cluster_info.name} successfully stopped.")
    except Exception as e:
        print(f"Error stopping cluster {cluster_info.name}: {e}")
```
