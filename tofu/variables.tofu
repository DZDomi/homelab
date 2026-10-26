variable "ups_snmp_auth_password" {
  type      = string
  sensitive = true

  # The RMCARD205 silently truncates longer SNMPv3 passwords
  validation {
    condition     = length(var.ups_snmp_auth_password) >= 8 && length(var.ups_snmp_auth_password) <= 31
    error_message = "Must be 8-31 characters."
  }
}

variable "ups_snmp_priv_password" {
  type      = string
  sensitive = true

  # The RMCARD205 silently truncates longer SNMPv3 passwords
  validation {
    condition     = length(var.ups_snmp_priv_password) >= 8 && length(var.ups_snmp_priv_password) <= 31
    error_message = "Must be 8-31 characters."
  }
}

variable "state_bucket" {
  description = "S3 bucket holding the OpenTofu state, created by bootstrap.tofu"
  type        = string
}
