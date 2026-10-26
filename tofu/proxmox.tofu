locals {
  lxc_containers = {
    nut = {
      vm_id  = 200
      memory = 256
      # Start first; Proxmox stops guests in reverse order, so NUT goes down last
      startup_order = 1
      // TODO: Adjust the IP
      network = {
        ip      = "10.1.3.50/24"
        gateway = "10.1.3.1"
      }
    }
  }

  ups = {
    name = "ups"
    ip   = "10.1.3.40"
    mibs = "cyberpower"
    # The RMCARD205 doesn't report it; dashboards need it to turn ups.load into watts
    realpower_nominal = 2700
    snmp = {
      sec_name      = "nut"
      sec_level     = "authPriv"
      auth_protocol = "SHA"
      priv_protocol = "AES"
    }
  }
}
