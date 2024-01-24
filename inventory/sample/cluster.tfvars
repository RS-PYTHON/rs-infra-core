#Global vars
cluster_name = "rs-cluster"

#Cluster vars
image_name = "OBS Ubuntu 22.04"

#To add another type of instance follow this template : 
#    instance = {
#        flavor = "<flavor>"
#        amount = <amount>
#        additionnal_disk_size = <additionnal_disk_size> # 0 if no additionnal disk wanted
#        type = "<instance-type>"
#        k8s_roles = ["list", "of", "roles"]
#    }
cluster_configuration = {
    #At least one master is required for the cluster to work fine
    master = {
        flavor = "s6.small.1"
        amount = 1
        additionnal_disk_size = 0
        type = "master"
        k8s_roles = ["kube_control_plane", "etcd"]
    }
    infra = {
        flavor = "s6.small.1"
        amount = 0 
        additionnal_disk_size = 0
        type = "infra"
        k8s_roles = ["infra"]
    }
    processing = {
        flavor = "s6.small.1"
        amount = 0
        additionnal_disk_size = 0
        type = "processing"
        k8s_roles = ["processing"]
    }
}
public_key = "<ssh-publickey>"

#Network vars
vpc_cidr = "192.168.0.0/16"
vpc_gateway_ip = "192.168.0.1"
vpc_subnet_cidr = "192.168.0.0/17"

nat_gw_spec = "1"

eip_nat_gw_type = "5_bgp"
eip_nat_gw_bandwidth = 10
eip_elb_type = "5_bgp"
eip_elb_bandwidth = 10

#Bucket vars
buckets = ["elasticsearch-processing", "elasticsearch-security", "thanos", "loki"]

