variable "host" {
  type = string
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "packages" {
  description = "apt packages to install"
  type        = list(string)
  default     = []
}

variable "files" {
  description = "Files to write, keyed by absolute path; written after the packages are installed"
  type = map(object({
    content = string
    owner   = optional(string, "root:root")
    mode    = optional(string, "0644")
  }))
  default = {}
}

variable "commands" {
  description = "Shell commands to run after the files are written"
  type        = list(string)
  default     = []
}

variable "triggers" {
  description = "Extra values that force a rerun when they change, e.g. the ID of a recreated host"
  type        = list(string)
  default     = []
}
