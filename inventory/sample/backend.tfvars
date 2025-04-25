#Backend S3
#One cluster's terraform.tfstate should not be stored at the same path (bucket/key)
#Or the newer installation will DESTROY the previous one
bucket = "some-bucket"
key = "terraform.tfstate"
region = "gra"
endpoint = "https://s3.gra.io.cloud.ovh.net"
