module "state_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.16.2"

  bucket                   = "${data.aws_caller_identity.current.account_id}-${local.region_short_names[data.aws_region.current.region]}-homelab-state"
  control_object_ownership = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }
}
