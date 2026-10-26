module "buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.16.2"

  for_each = toset(local.aws_buckets)

  bucket                   = "${data.aws_caller_identity.current.account_id}-${local.region_short_names[data.aws_region.current.region]}-${each.value}"
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

resource "b2_bucket" "buckets" {
  for_each = local.backblaze_buckets

  bucket_name = "${data.b2_account_info.current.account_id}-${each.key}"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    mode      = "SSE-B2"
    algorithm = "AES256"
  }

  dynamic "lifecycle_rules" {
    for_each = each.value.days_from_hiding_to_deleting == null ? [] : [each.value.days_from_hiding_to_deleting]

    content {
      file_name_prefix             = ""
      days_from_hiding_to_deleting = lifecycle_rules.value
    }
  }
}

resource "b2_application_key" "buckets" {
  for_each = b2_bucket.buckets

  key_name = each.key
  # Keys created with bucket_ids only work with B2 API v4; the deprecated single-bucket
  # bucket_id form also works with API v1
  bucket_id  = local.backblaze_buckets[each.key].api_v1_key ? each.value.bucket_id : null
  bucket_ids = local.backblaze_buckets[each.key].api_v1_key ? null : [each.value.bucket_id]
  capabilities = concat(
    [
      "listBuckets",
      "readBuckets",
      "readBucketEncryption",
      "listFiles",
      "readFiles",
      "writeFiles",
    ],
    local.backblaze_buckets[each.key].allow_delete ? ["deleteFiles"] : [],
  )
}
