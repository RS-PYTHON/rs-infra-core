# create-cluster module
variable "image_name" {
    description = "image name"
    type        = string
}

variable "master_flavor" {
    description = "master flavor"
    type        = string
}

variable "master_amount" {
    description = "number of gateway to create"
    type        = number
}

variable "gateway_flavor" {
    description = "gateway flavor"
    type        = string
}

variable "gateway_amount" {
    description = "number of gateway to create"
    type        = number
}

variable "infra_flavor" {
    description = "infra flavor"
    type        = string
}

variable "infra_amount" {
    description = "number of infra to create"
    type        = number
}

variable "vpc_cidr" {
    description = "network cidr"
    type        = string
}

variable "vpc_subnet_cidr" {
    description = "subnet cidr"
    type        = string
}

module "create-cluster" {
    source = "./modules/create-cluster"
    image_name = var.image_name
    master_flavor = var.master_flavor
    master_amount = var.master_amount
    gateway_flavor = var.gateway_flavor
    gateway_amount = var.gateway_amount
    infra_flavor = var.infra_flavor
    infra_amount = var.infra_amount
    vpc_cidr = var.vpc_cidr
    vpc_subnet_cidr = var.vpc_subnet_cidr
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