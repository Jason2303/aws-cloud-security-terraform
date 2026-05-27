resource "aws_s3_bucket" "KMS-locked" {
  bucket = "jimmybucket36571"

  tags = {
    Name        = "My bucket"
    Environment = "CF"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse-kms" {
  bucket = aws_s3_bucket.KMS-locked.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> e1d3e9b4984b70f969defe4100fef9dd6c2dc834
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.KMS-locked.id
  acl    = "private"
}

<<<<<<< HEAD
>>>>>>> main
=======

>>>>>>> e1d3e9b4984b70f969defe4100fef9dd6c2dc834
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.KMS-locked.id
  versioning_configuration {
    status = "Enabled"
  }
}



