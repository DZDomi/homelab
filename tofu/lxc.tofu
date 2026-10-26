locals {
  ssh_public_key  = trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))
  ssh_private_key = file(pathexpand("~/.ssh/id_ed25519"))

  # What gets installed and configured inside each container in local.lxc_containers
  lxc_provisioning = {
    nut = local.nut_provisioning
  }
}

module "lxc" {
  source = "./modules/lxc"

  for_each = local.lxc_containers

  node_name       = "pve"
  datastore_id    = "local-lvm"
  ssh_public_key  = local.ssh_public_key
  ssh_private_key = local.ssh_private_key

  vm_id         = each.value.vm_id
  hostname      = each.key
  tags          = [each.key]
  cores         = try(each.value.cores, 1)
  memory        = try(each.value.memory, 512)
  disk_size     = try(each.value.disk_size, 4)
  startup_order = try(each.value.startup_order, null)
  network       = each.value.network
  template      = try(each.value.template, null)
  provisioning  = local.lxc_provisioning[each.key]
}
