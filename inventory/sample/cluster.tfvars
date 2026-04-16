# Global vars
## TO DO : use var from inventory instead
cluster_name = "rs-cluster"
region = "GRA11"
allowed_ip_list = ["5.6.7.8", "1.2.3.4"]

# If you have a valid public docker.io account, set it here, else leave empty but do not remove
public_dockerhub_user = ""
public_dockerhub_pass = ""

# Nodepools vars
nodepool_infra_desired_nodes = 2
nodepool_rs_server_desired_nodes = 1
nodepool_rs_env_desired_nodes = 1
nodepool_access_csc_desired_nodes = 1
nodepool_prefect_flow_desired_nodes = 0
nodepool_dask_scheduler_desired_nodes = 0
nodepool_dask_worker_on_demand_desired_nodes = 0

nodepool_infra_autoscale = true
nodepool_rs_server_autoscale = true
nodepool_rs_env_autoscale = true
nodepool_access_csc_autoscale = true
nodepool_prefect_flow_autoscale = true
nodepool_dask_scheduler_autoscale = true
nodepool_dask_worker_on_demand_autoscale = true

nodepool_prefect_flow_min_nodes = 0

nodepool_dask_scheduler_max_nodes = 1

# Bucket vars
buckets = ["loki", "tempo", "psql", "velero"]
buckets_region = "gra"
