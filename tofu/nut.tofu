locals {
  nut_ip = split("/", local.lxc_containers.nut.network.ip)[0]

  nut_provisioning = {
    packages = ["nut-server", "nut-client", "nut-snmp"]
    files = {
      for name, content in {
        "nut.conf"    = "MODE=netserver\n"
        "ups.conf"    = templatefile("${path.module}/templates/nut/ups.conf.tftpl", { ups = local.ups, auth_password = var.ups_snmp_auth_password, priv_password = var.ups_snmp_priv_password })
        "upsd.conf"   = "LISTEN 0.0.0.0 3493\n"
        "upsd.users"  = templatefile("${path.module}/templates/nut/upsd.users.tftpl", { primary_password = random_password.nut["primary"].result, secondary_password = random_password.nut["secondary"].result })
        "upsmon.conf" = templatefile("${path.module}/templates/nut/upsmon-server.conf.tftpl", { ups = local.ups.name, password = random_password.nut["primary"].result })
      } : "/etc/nut/${name}" => { content = content, owner = "root:nut", mode = "0640" }
    }
    commands = [
      # resync exits 42 when it creates the driver instance (fresh container)
      "REPORT_RESTART_42=no upsdrvsvcctl resync",
      "systemctl enable nut-server nut-monitor",
      # upsd/upsmon start without a working driver; restart them first so a driver
      # failure (e.g. SNMP auth) still fails the apply but leaves the server running
      "systemctl restart nut-server nut-monitor",
      "systemctl restart nut-driver.target",
    ]
  }
}

resource "random_password" "nut" {
  for_each = toset(["primary", "secondary"])

  length  = 32
  special = false
}

output "nut_secondary" {
  value = {
    server   = "${local.ups.name}@${local.nut_ip}"
    user     = "secondary"
    password = random_password.nut["secondary"].result
  }
  sensitive = true
}
