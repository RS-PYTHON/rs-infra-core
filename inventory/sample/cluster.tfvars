image_name = "OBS Ubuntu 22.04"
vpc_cidr = "192.168.0.0/16"
vpc_subnet_cidr = "192.168.0.0/17"

cluster_configuration = {
    master = {
        flavor = "s6.small.1"
        amount = 1
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

public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPm/faFdHGZ1smWQ/yBFAB/YlsYRdpKj9OfPCwFAyc5vhg4SLGBDhgIdwOeDMxpffOwxdapH1Zaph4mponQx+b9kqJ7NdCvh3u7EkarVmnEjbTd9dzZMQ+Xbz6WZEF6zRXaqSe5SgE7NsqgGalo2wT9NDUFXqIzX+eV4z9b2xUz+c0ZDCw9t0XQc2QQSlbxjWnyPcTiyk9Nm59a8wHXWWTerUdh821HVRlfYucwW1q17WSvuiH+bJh1pyOj7RzEhZ/3tPHE1BTiMerXO5ZnPk/VB/IIjWsmpDIBKoWi6+bXpoHjPpWtbNLg9lfOxSgNOaCMvwV0FtrPiqbru2uR5Gd"