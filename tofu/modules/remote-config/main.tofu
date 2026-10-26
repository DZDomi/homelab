resource "terraform_data" "this" {
  # Rerun whenever anything that ends up on the host changes
  triggers_replace = concat(var.triggers, [
    sha256(jsonencode([var.packages, var.files, var.commands])),
  ])

  connection {
    host        = var.host
    user        = "root"
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = concat(
      ["set -eu", "export DEBIAN_FRONTEND=noninteractive"],
      length(var.packages) == 0 ? [] : [
        "apt-get update -qq",
        "apt-get install -y -qq ${join(" ", var.packages)}",
      ],
      # base64 keeps arbitrary file content safe from shell quoting
      flatten([
        for path, file in var.files : [
          "install -d ${dirname(path)}",
          "echo '${base64encode(file.content)}' | base64 -d > ${path}",
          "chown ${file.owner} ${path}",
          "chmod ${file.mode} ${path}",
        ]
      ]),
      var.commands,
    )
  }
}
