data "talos_client_configuration" "cluster" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.cluster.client_configuration
  endpoints = [
    local.controlplane.domain
  ]
  nodes = [
    local.controlplane.domain
  ]
}

resource "talos_cluster_kubeconfig" "cluster" {
  client_configuration = talos_machine_secrets.cluster.client_configuration
  node                 = local.controlplane.domain
}

resource "local_file" "talosconfig" {
  filename        = pathexpand("~/.talos/config")
  file_permission = "0644"
  content         = data.talos_client_configuration.cluster.talos_config
}

resource "local_file" "kubeconfig" {
  filename        = pathexpand("~/.kube/config")
  file_permission = "0644"
  content         = talos_cluster_kubeconfig.cluster.kubeconfig_raw
}

output "b2_application_keys" {
  value = {
    for name, key in b2_application_key.buckets : name => {
      id  = key.application_key_id
      key = key.application_key
    }
  }
  sensitive = true
}
