data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "b2_account_info" "current" {}

data "talos_image_factory_extensions_versions" "cluster" {
  talos_version = local.talos_version
  filters = {
    names = local.talos_extensions
  }
}

resource "talos_image_factory_schematic" "cluster" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.cluster.extensions_info.*.name
      }
    }
  })
}