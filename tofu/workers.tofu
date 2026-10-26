data "talos_machine_configuration" "workers" {
  for_each = local.workers

  talos_version      = local.talos_version
  kubernetes_version = local.kubernetes_version

  cluster_name     = local.cluster_name
  machine_type     = "worker"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets

  config_patches = [
    for patch in concat(
      local.config_patches_common,
      local.config_patches_node.workers[each.key],
    ) : yamlencode(patch)
  ]
}

resource "talos_machine_configuration_apply" "workers" {
  for_each = local.workers

  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers[each.key].machine_configuration
  node                        = each.value.ip
}