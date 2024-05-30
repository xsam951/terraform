# create s3 bucket
resource "aws_s3_bucket" "tf-state" {  
    bucket = "XXXXXXXXXXXXXXXXXXXX"
  acl    = "private"
  versioning {
    enabled = true
  }
}

# create dynamodb table
resource "aws_dynamodb_table" "tf-locks" {
    name         = "XXXXXXXXXXXXXXXXXXXX"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# create s3 bucket policy
resource "aws_s3_bucket_policy" "tf-state-bucket-policy" {
  bucket = aws_s3_bucket.tf-state.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyInsecureUsage",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.tf-state.arn}",
        "${aws_s3_bucket.tf-state.arn}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

# create dynamodb table policy
resource "aws_iam_policy" "tf-state-dynamodb-policy" {
  name = "XXXXXXXXXXXXXXXXXXXX"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "${aws_dynamodb_table.tf-locks.arn}"
    }
  ]
}
POLICY
}

# create iam role
resource "aws_iam_role" "tf-state-role" {
    name = "XXXXXXXXXXXXXXXXXXXX"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "terraform.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# attach policy to iam role
resource "aws_iam_role_policy_attachment" "tf-state-role-policy-attach" {
    role = aws_iam_role.tf-state-role.name
  policy_arn = aws_iam_policy.tf-state-dynamodb-policy.arn
}

# create iam role
resource "aws_iam_role" "tf-state-role-2" {
    name = "XXXXXXXXXXXXXXXXXXXX"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# attach policy to iam role
resource "aws_iam_role_policy_attachment" "tf-state-role-policy-attach-2" {
    role = aws_iam_role.tf-state-role-2.name
  policy_arn = aws_iam_policy.tf-state-dynamodb-policy.arn
}

# create iam instance profile
resource "aws_iam_instance_profile" "tf-state-profile" {
    name = "XXXXXXXXXXXXXXXXXXXX"
  role = aws_iam_role.tf-state-role-2.name
}
