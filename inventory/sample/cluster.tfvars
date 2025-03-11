# Global vars
cluster_name = "rs-cluster"
region = "GRA11"
allowed_ip_list = ["5.6.7.8", "1.2.3.4"]

# Nodepools vars
nodepool_infra_desired_nodes = 3
nodepool_infra_autoscale = true
nodepool_processing_desired_nodes = 1
nodepool_processing_autoscale = true
nodepool_access_csc_desired_nodes = 1
nodepool_access_csc_autoscale = true
nodepool_prefect_desired_nodes = 0
nodepool_prefect_autoscale = true
nodepool_processing_ondemand_desired_nodes = 0
nodepool_processing_ondemand_autoscale = true
nodepool_processing_systematic_desired_nodes = 0
nodepool_processing_systematic_autoscale = true

# Bucket vars
buckets = ["loki", "tempo", "psql", "velero"]
buckets_region = "gra"
