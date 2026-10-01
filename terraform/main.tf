# Generated via GitHub Copilot: Standard S3 bucket for application assets with strict public access blocks
provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "app_assets" {
  bucket = "ai-pipeline-frontend-assets-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "app_assets_block" {
  bucket = aws_s3_bucket.app_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
