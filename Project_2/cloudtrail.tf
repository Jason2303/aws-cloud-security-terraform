resource "aws_s3_bucket" "trails" {
  bucket = "cloudtraillogs099"

  tags = {
    Name        = "My bucket_2"
    Environment = "CF"
  }
}

resource "aws_s3_bucket_versioning" "trails_versioning" {
  bucket = aws_s3_bucket.trails.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trails_sse" {
  bucket = aws_s3_bucket.trails.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_for_CloudTrail" {
  bucket = aws_s3_bucket.trails.id
  policy = data.aws_iam_policy_document.allow_access_for_CloudTrail.json
}

data "aws_iam_policy_document" "allow_access_for_CloudTrail" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",

    ]

    resources = [
      aws_s3_bucket.trails.arn,
    ]
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",

    ]

    resources = [
      "${aws_s3_bucket.trails.arn}/*"
    ]
  }
}

resource "aws_cloudtrail" "cloudtrail_logs" {
  depends_on = [aws_s3_bucket_policy.allow_access_for_CloudTrail]

  name                          = "cloudtrail"
  s3_bucket_name                = aws_s3_bucket.trails.id
  include_global_service_events = true
  enable_log_file_validation    = true
  is_multi_region_trail         = true
  kms_key_id                    = aws_kms_key.kms-key.arn
}


data "aws_partition" "current" {}

data "aws_region" "current" {}