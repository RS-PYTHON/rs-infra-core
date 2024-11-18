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
#        k8s_roles = "list of roles separated by spaces"
#        node_labels = "list of kubernetes labels separated by semicolons"
#        node_taints = "list of kubernetes taints separated by semicolons"
#    }
cluster_configuration = {
    #At least one master is required for the cluster to work fine
    master = {
        flavor = "s6.small.1"
        amount = 1
        additionnal_disk_size = 0
        type = "master"
        k8s_roles = "kube_control_plane etcd"
        node_labels = "node-role.kubernetes.io/master: ''"
        node_taints = "role=basic:NoSchedule"
    }
    infra = {
        flavor = "s6.small.1"
        amount = 1 
        additionnal_disk_size = 0
        type = "infra"
        k8s_roles = "infra"
        node_labels = "node-role.kubernetes.io/infra: ''"
        node_taints = ""
    }
    processing = {
        flavor = "s6.small.1"
        amount = 0
        additionnal_disk_size = 0
        type = "processing"
        k8s_roles = "processing"
        node_labels = ""
        node_taints = ""
    }
    daskcluster = {
        flavor = "s6.small.1"
        amount = 0
        additionnal_disk_size = 0
        type = "daskcluster"
        k8s_roles = "daskcluster"
        node_labels = "node-role.kubernetes.io/daskcluster: ''"
        node_taints = "role=access_csc:NoSchedule"
    }
    ondemanddpr = {
        flavor = "s6.small.1"
        amount = 0
        additionnal_disk_size = 0
        type = "ondemanddpr"
        k8s_roles = "ondemanddpr"
        node_labels = "node-role.kubernetes.io/ondemand_dpr: ''"
        node_taints = "role=ondemand_dpr:NoSchedule"
    }
    systematicdpr = {
        flavor = "s6.small.1"
        amount = 0
        additionnal_disk_size = 0
        type = "systematicdpr"
        k8s_roles = "systematicdpr"
        node_labels = "node-role.kubernetes.io/systematic_dpr: ''"
        node_taints = "role=systematic_dpr:NoSchedule"
    }
    prefectflow = {
        flavor = "s6.small.1"
        amount = 0
        additionnal_disk_size = 0
        type = "prefectflow"
        k8s_roles = "prefectflow"
        node_labels = "node-role.kubernetes.io/prefect_flow: ''"
        node_taints = "role=prefect_flow:NoSchedule"
    }
}
public_key = "<ssh-publickey>"

#Network vars
vpc_cidr = "192.168.0.0/16"
vpc_gateway_ip = "192.168.0.1"
vpc_subnet_cidr = "192.168.0.0/17"
vpc_subnet_primary_dns = "100.125.0.41"
vpc_subnet_secondary_dns = "100.126.0.41"

nat_gw_spec = "1"

eip_nat_gw_type = "5_bgp"
eip_nat_gw_bandwidth = 10
eip_elb_type = "5_bgp"
eip_elb_bandwidth = 10

#Bucket vars
buckets = ["elasticsearch-processing", "elasticsearch-security", "thanos", "loki", "tempo", "psql"]
