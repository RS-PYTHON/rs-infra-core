# create-cluster module
variable "image_name" {
    description = "image name"
    type        = string
}

variable "vpc_cidr" {
    description = "network cidr"
    type        = string
}

variable "vpc_subnet_cidr" {
    description = "subnet cidr"
    type        = string
}

variable "cluster_configuration" {
    description = "infrastructure configuration"
    type        = map(object({
      flavor    = string
      amount    = number
      type      = string
      additionnal_disk_size = number
    }))
}


module "create-cluster" {
    source = "./modules/create-cluster"
    image_name = var.image_name
    vpc_cidr = var.vpc_cidr
    vpc_subnet_cidr = var.vpc_subnet_cidr
    cluster_configuration = var.cluster_configuration
}

#create-buckets module

variable "buckets" {
    description = "bucket list"
    type        = list(string)
}

module "create-buckets" {
    source = "./modules/create-buckets"
    buckets = var.buckets
}