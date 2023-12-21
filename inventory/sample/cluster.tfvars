image_name = "OBS Ubuntu 20.04"
vpc_cidr = "192.168.0.0/16"
vpc_subnet_cidr = "192.168.0.0/17"

cluster_configuration = {
    master = {
        flavor = "s6.small.1"
        amount = 2
        additionnal_disk_size = 0
        type = "master"
    }
    infra = {
        flavor = "s6.small.1"
        amount = 0
        additionnal_disk_size = 0
        type = "infra"
    }
    processing = {
        flavor = "s6.small.1"
        amount = 0
        additionnal_disk_size = 0
        type = "processing"
    }
}

cluster_name = "rs-cluster"
buckets = ["elasticsearch-processing", "elasticsearch-security", "thanos", "loki"]