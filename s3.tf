# create s3 bucket
resource "aws_s3_bucket" "s3_buck"  {  
  bucket = "sam_s3_bucket_deham14"
  versioning {
    enabled = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}