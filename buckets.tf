resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = var.bucket_force_destroy
  tags          = merge(var.tags)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key.id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.bucket_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "log"
    status = var.enable_logs_s3_sync && var.log_auto_clean ? "Enabled" : "Disabled"

    prefix = "logs/"

    transition {
      days          = var.log_standard_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.log_glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_expiry_days
    }
  }
}
