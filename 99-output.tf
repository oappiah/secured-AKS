data "template_file" "summary" {
  template = file("${path.module}/summary.tpl")

  vars = {
    username          = var.username
    location          = var.location
    fgtpip            = azurerm_public_ip.fgtpip.ip_address
  }
}

output "deployment_summary" {
  value = data.template_file.summary.rendered
}
