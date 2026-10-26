terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

# Prefixed with the VM ID so containers sharing a template don't fight over one file
resource "proxmox_download_file" "template" {
  node_name          = var.node_name
  datastore_id       = var.template.datastore_id
  content_type       = "vztmpl"
  file_name          = "${var.vm_id}-${basename(var.template.url)}"
  url                = var.template.url
  checksum           = var.template.checksum
  checksum_algorithm = var.template.checksum_algorithm
}

resource "proxmox_virtual_environment_container" "this" {
  node_name     = var.node_name
  vm_id         = var.vm_id
  description   = var.description
  tags          = concat(var.tags, ["tofu"])
  unprivileged  = true
  start_on_boot = true

  dynamic "startup" {
    for_each = var.startup_order == null ? [] : [var.startup_order]

    content {
      order = startup.value
    }
  }

  operating_system {
    template_file_id = proxmox_download_file.template.id
    type             = var.os_type
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  # systemd in unprivileged containers needs nesting
  features {
    nesting = true
  }

  network_interface {
    name    = "eth0"
    bridge  = var.network.bridge
    vlan_id = var.network.vlan_id
  }

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = var.network.ip
        gateway = var.network.gateway
      }
    }

    user_account {
      keys = [var.ssh_public_key]
    }
  }
}

module "config" {
  source = "../remote-config"

  host            = local.ip
  ssh_private_key = var.ssh_private_key
  packages        = var.provisioning.packages
  files           = var.provisioning.files
  commands        = var.provisioning.commands
  triggers        = [proxmox_virtual_environment_container.this.id]
}

locals {
  ip = split("/", var.network.ip)[0]
}
