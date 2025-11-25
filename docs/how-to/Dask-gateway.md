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

### Create single cluster (without option) (Option 1)

``` Python
cluster = gateway.new_cluster()
print (cluster.name)
```

### Create a basic cluster with options (Option 2)

``` Python
# List of options available
options = gateway.cluster_options()

for key in options.keys():
    print(f"{key}: {options[key]}")

cluster = gateway.new_cluster(worker_cores=1, worker_memory=2.0, namespace='dask-gateway', image='ghcr.io/rs-python/dask/s1ard:latest')

print (cluster.name)
gateway.scale_cluster(cluster.name, 3)
```

### Create a staging cluster with options (Option 3)

``` Python
# List of options available
options = gateway.cluster_options()

for key in options.keys():
    print(f"{key}: {options[key]}")

cluster = gateway.new_cluster(worker_cores=1, worker_memory=2.0, namespace='dask-gateway', image='ghcr.io/rs-python/dask/staging:latest', cluster_name='dask-staging', scheduler_extra_pod_labels={'cluster_name': 'dask-staging'})

print (cluster.name)
gateway.scale_cluster(cluster.name, 3)
```

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
