#Backend S3
#One cluster's terraform.tfstate should not be stored at the same path (bucket/key)
#Or the newer installation will DESTROY the previous one
bucket = "some-bucket"
key = "terraform.tfstate"
region = "eu-west-0"
endpoint = "https://oss.eu-west-0.prod-cloud-ocb.orange-business.com"