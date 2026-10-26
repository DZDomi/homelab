terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.9.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.12.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.67.0"
    }
    b2 = {
      source  = "Backblaze/b2"
      version = "0.14.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.116.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}

provider "talos" {}

provider "aws" {
  region = "eu-central-1"
}

provider "b2" {}

provider "proxmox" {
  endpoint = "https://pve.${local.domain}:8006/"
  insecure = true
}
