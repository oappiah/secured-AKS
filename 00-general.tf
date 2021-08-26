terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.prefix}-RG"
  location = var.location
}
data "template_file" "inventory" {
  template = file("${path.module}/inventory.tpl")
  vars = {
    fgt_username = var.username
    fgtpip = azurerm_public_ip.fgtpip.ip_address
  }
}

resource "local_file" "inventory" {
  filename = "files/inventory"
  content = data.template_file.inventory.rendered
}

data "template_file" "post" {
  template = file("${path.module}/post.tpl")

  vars = {
    fgtpip = azurerm_public_ip.fgtpip.ip_address
    auto_password = random_password.autouser_password.result
    crg = azurerm_kubernetes_cluster.k8s.node_resource_group
  }
}
resource "tls_private_key" "demokey" {
  algorithm   = "RSA"
  ecdsa_curve = "P384"
}

resource "local_file" "demokey" {
  filename = "files/demokey.pem"
  content = tls_private_key.demokey.private_key_pem
  file_permission = 0700
}

resource "local_file" "post" {
  filename = "files/post.yaml"
  content = data.template_file.post.rendered
}
