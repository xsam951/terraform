# create s3 bucket
resource "aws_s3_bucket" "s3_bucket"  {  
  bucket = "sam_s3_bucket_deham14"
  
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

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}