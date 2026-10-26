locals {
  domain = "example.com"

  # renovate: datasource=github-releases depName=siderolabs/talos
  talos_version = "v1.14.4"
  # renovate: datasource=github-releases depName=kubernetes/kubernetes
  kubernetes_version = "v1.37.0"

  talos_extensions = [
    "iscsi-tools"
  ]

  cluster_name     = "main"
  cluster_endpoint = "https://${local.controlplane.domain}:6443"

  install_image = "factory.talos.dev/metal-installer/${talos_image_factory_schematic.cluster.id}:${local.talos_version}"
  upgrade_image = "factory.talos.dev/installer/${talos_image_factory_schematic.cluster.id}:${local.talos_version}"

  controlplane = {
    domain = "controlplane.k8s.${local.domain}"
    ip     = "10.1.3.21"
  }

  workers = {
    first = {
      domain = "first.worker.k8s.${local.domain}"
      ip     = "10.1.3.31"
    }
    second = {
      domain = "second.worker.k8s.${local.domain}"
      ip     = "10.1.3.32"
    }
  }

  # Talos >= 1.14 multi-document config, patched on top of the generated documents
  config_patches_common = [
    {
      apiVersion = "v1alpha1"
      kind       = "ResolverConfig"
      nameservers = [
        { address = "1.1.1.2" },
        { address = "1.0.0.2" }
      ]
    },
    {
      apiVersion     = "v1alpha1"
      kind           = "KubeNetworkConfig"
      podSubnets     = ["172.16.0.0/16"]
      serviceSubnets = ["172.17.0.0/16"]
    },
    # Keep pre-1.14 behavior for the existing cluster
    {
      apiVersion = "v1alpha1"
      kind       = "SecurityProfileConfig"
      "$patch"   = "delete"
    },
    {
      apiVersion = "v1alpha1"
      kind       = "VolumeConfig"
      name       = "EPHEMERAL"
      "$patch"   = "delete"
    },
  ]

  config_patches_controlplane = [
    # Cilium is the CNI and replaces kube-proxy
    {
      apiVersion = "v1alpha1"
      kind       = "KubeFlannelCNIConfig"
      "$patch"   = "delete"
    },
    {
      apiVersion = "v1alpha1"
      kind       = "KubeProxyConfig"
      enabled    = false
    },
    {
      apiVersion = "v1alpha1"
      kind       = "KubeAdmissionControlConfig"
      name       = "PodSecurity"
      configuration = {
        apiVersion = "pod-security.admission.config.k8s.io/v1alpha1"
        kind       = "PodSecurityConfiguration"
        defaults = {
          enforce         = "baseline"
          enforce-version = "latest"
          warn            = "baseline"
          warn-version    = "latest"
          audit           = "baseline"
          audit-version   = "latest"
        }
        exemptions = {
          namespaces = [
            "democratic-csi",
            "home-assistant",
            "prometheus"
          ]
          runtimeClasses = []
          usernames      = []
        }
      }
    },
  ]

  config_patches_node = {
    controlplane = [
      {
        machine = {
          certSANs = [
            local.controlplane.domain
          ]
        }
      },
      {
        apiVersion = "v1alpha1"
        kind       = "UnattendedInstallConfig"
        installer = {
          image = local.install_image
        }
        provisioning = {
          diskSelector = {
            match = "disk.dev_path == \"/dev/sda\""
          }
        }
      },
      {
        apiVersion = "v1alpha1"
        kind       = "KubeNodeConfig"
        labels = {
          "vlan.example.com/servers" = "true"
        }
        # Allow scheduling on the control plane
        taints = {
          "$patch" = "delete"
        }
      },
    ]
    workers = {
      first = [
        {
          machine = {
            certSANs = [
              local.workers.first.domain
            ]
          }
        },
        {
          apiVersion = "v1alpha1"
          kind       = "UnattendedInstallConfig"
          installer = {
            image = local.install_image
          }
          provisioning = {
            diskSelector = {
              match = "disk.dev_path == \"/dev/nvme0n1\""
            }
          }
        },
        {
          apiVersion = "v1alpha1"
          kind       = "KubeNodeConfig"
          labels = {
            "vlan.example.com/servers"  = "true"
            "vlan.example.com/external" = "true"
          }
        },
      ]
      second = [
        {
          machine = {
            certSANs = [
              local.workers.second.domain
            ]
          }
        },
        {
          apiVersion = "v1alpha1"
          kind       = "UnattendedInstallConfig"
          installer = {
            image = local.install_image
          }
          provisioning = {
            diskSelector = {
              match = "disk.dev_path == \"/dev/nvme0n1\""
            }
          }
        },
        {
          apiVersion = "v1alpha1"
          kind       = "KubeNodeConfig"
          labels = {
            "vlan.example.com/servers"  = "true"
            "vlan.example.com/external" = "true"
          }
        },
      ]
    }
  }

  aws_buckets = []
  # days_from_hiding_to_deleting: purge old/deleted file versions after N days, null keeps all versions
  # allow_delete: whether the bucket's application key may permanently delete file versions
  # api_v1_key: create the key in the single-bucket form, needed by clients on B2 API v1 (rclone)
  backblaze_buckets = {
    # Without delete, a compromised NAS can only hide files; old versions stay recoverable
    "homelab-truenas-cloud-sync" = {
      days_from_hiding_to_deleting = null
      allow_delete                 = false
      api_v1_key                   = true
    }
    # Kopia maintenance needs to delete unreferenced blobs
    "homelab-velero-backups" = {
      days_from_hiding_to_deleting = 1
      allow_delete                 = true
      api_v1_key                   = false
    }
  }
}
