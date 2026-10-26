variable "node_name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "hostname" {
  type = string
}

variable "description" {
  type    = string
  default = "Managed by OpenTofu"
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "template" {
  description = "LXC template downloaded to the node for this container"
  type = object({
    url                = string
    checksum           = string
    checksum_algorithm = optional(string, "sha512")
    datastore_id       = optional(string, "local")
  })
  default = {
    url      = "http://download.proxmox.com/images/system/debian-13-standard_13.6-1_amd64.tar.zst"
    checksum = "4c0c27ca6ceab5ef0b84db57825a00f26157ef1854bafe97297813e1cbe8ecb8cc9c453cab6b3b0efe1ba193a50c47ece1e41d950e411b8730b835b71e9e754b"
  }
  nullable = false
}

variable "os_type" {
  type    = string
  default = "debian"
}

variable "cores" {
  type    = number
  default = 1
}

variable "memory" {
  description = "Memory in MiB"
  type        = number
  default     = 512
}

variable "swap" {
  description = "Swap in MiB"
  type        = number
  default     = 512
}

variable "datastore_id" {
  type = string
}

variable "disk_size" {
  description = "Root disk size in GB"
  type        = number
  default     = 4
}

variable "startup_order" {
  description = "Boot order; Proxmox stops guests in reverse order"
  type        = number
  default     = null
}

variable "network" {
  type = object({
    ip      = string # CIDR, e.g. 10.1.3.40/24
    gateway = string
    bridge  = optional(string, "vmbr0")
    vlan_id = optional(number)
  })
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "provisioning" {
  description = "Passed to the remote-config module once the container is up"
  type = object({
    packages = optional(list(string), [])
    files = optional(map(object({
      content = string
      owner   = optional(string, "root:root")
      mode    = optional(string, "0644")
    })), {})
    commands = optional(list(string), [])
  })
  default = {}
}
