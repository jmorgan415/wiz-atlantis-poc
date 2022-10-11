# Create resource group
resource "azurerm_resource_group" "demo" {
  name     = var.rg_name
  location = "Central US"
  tags = {
    Environment = "atlantis-demo"
  }
}
