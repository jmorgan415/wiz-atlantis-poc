# Azure Info
provider "azurerm" {
  features {}
  client_id     = var.arm_client_id
  client_secret = var.arm_client_secret
  tenant_id     = var.arm_tenant_id
}

# Create resource group
resource "azurerm_resource_group" "demo" {
  name     = var.config[terraform.workspace].rg_name
  location = "Central US"
  tags = {
    Environment = "atlantis"
  }
}
