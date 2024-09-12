# Dask Gateway

## Prerequisite

Install following libraries on the terminal before applying the commands below:

``` bash
pip install dask-gateway==2024.1.0 dask==2024.1.0 distributed==2024.1.0 msgpack==1.0.7 numpy==1.26.3 pandas==2.1.4 toolz==0.12.0
```

## Connect to the Gateway

``` Python
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

### Create single cluster (without option)

``` Python
cluster = gateway.new_cluster()
print (cluster.name)
```

### Create cluster with options

``` Python
# List of options available
options = gateway.cluster_options()

for key in options.keys():
    print(f"{key}: {options[key]}")


cluster = gateway.new_cluster(worker_cores=1, worker_memory=4.0, namespace='dask-gateway')
print (cluster.name)
gateway.scale_cluster(cluster.name, 2)
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
