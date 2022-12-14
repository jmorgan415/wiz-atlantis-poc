terraform {
  #required_version = ">= 0.13.1"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.26.0"
    }
  }
}

# Azure
provider "azurerm" {
  features {}
}
