resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "my-bucket-${random_id.bucket_id.hex}"
  force_destroy = true
  tags = {
    Name = "My bucket-${var.region}"
  }
}