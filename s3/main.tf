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
