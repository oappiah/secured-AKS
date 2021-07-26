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

# For the Azure SDN Connector
data "azuread_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "azuread_application" "fgtconnector" {
  display_name     = "fgtconnector"
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "fgtconnector_sp" {
  application_id               = azuread_application.fgtconnector.application_id
  app_role_assignment_required = false
}

resource "azurerm_role_assignment" "fgtconnector_access" {
  scope              = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id       = azuread_service_principal.fgtconnector_sp.id
}

  resource "azuread_service_principal_password" "fgtconnector_password" {
    service_principal_id = azuread_service_principal.fgtconnector_sp.object_id
  }
