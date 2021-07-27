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
