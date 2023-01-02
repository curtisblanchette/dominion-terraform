resource "aws_s3_bucket" "dominion_ui_s3bucket" {
  bucket        = "${var.name}-ui-${var.environment}"
  force_destroy = true

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "dominion_frontend_s3bucket_website_configuration" {
  bucket = aws_s3_bucket.dominion_ui_s3bucket.bucket

  index_document {
    suffix = "index.html"
  }
}

output "s3_bucket_dns_name" {
  value = aws_s3_bucket.dominion_ui_s3bucket.bucket_regional_domain_name
}

resource "aws_s3_bucket_policy" "allow_access_from_internet" {
  bucket = aws_s3_bucket.dominion_ui_s3bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_internet.json
}

data "aws_iam_policy_document" "allow_access_from_internet" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.dominion_ui_s3bucket.arn,
      "${aws_s3_bucket.dominion_ui_s3bucket.arn}/*",
    ]
  }
}


resource "aws_s3_bucket" "dominion_config" {
  bucket        = "${var.name}-config"
  force_destroy = true

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

# Important Factoid:
# when re-creating a bucket with a previously used name -- for example: you just deleted it
# the (globally unique) name availability may take up to 1 hour to be released
resource "aws_s3_object" "dominion_config_dev" {
  bucket = aws_s3_bucket.dominion_config.id
  key    = "${var.environment}.yml"
  source = file("/Users/curtisblanchette/code/s3.dominion-config/${var.environment}.yml")

  # (Optional) Triggers updates when the value changes.
  # The only meaningful value is filemd5("path/to/file") (Terraform 0.11.12 or later) or ${md5(file("path/to/file"))} (Terraform 0.11.11 or earlier).
  # This attribute is not compatible with KMS encryption, kms_key_id or server_side_encryption = "aws:kms" (see source_hash instead).
  # etag   = filemd5("/Users/curtisblanchette/code/s3.dominion-config/${var.environment}.yml")
}
