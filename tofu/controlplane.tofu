data "talos_machine_configuration" "controlplane" {
  talos_version      = local.talos_version
  kubernetes_version = local.kubernetes_version

  cluster_name     = local.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets

  config_patches = [
    for patch in concat(
      local.config_patches_common,
      local.config_patches_controlplane,
      local.config_patches_node.controlplane,
    ) : yamlencode(patch)
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.cluster.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.controlplane.domain
}

resource "talos_machine_bootstrap" "controlplane" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
  client_configuration = talos_machine_secrets.cluster.client_configuration
  node                 = local.controlplane.domain
}