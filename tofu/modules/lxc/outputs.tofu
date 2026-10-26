output "ip" {
  value = local.ip
}

output "id" {
  value = proxmox_virtual_environment_container.this.id
}
