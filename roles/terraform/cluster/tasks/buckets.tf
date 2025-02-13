
resource "aws_s3_bucket" "buckets" {
  for_each = toset(var.buckets)
  bucket = "${each.value}-${var.cluster_name}"
}