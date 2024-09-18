terraform {
  required_version = "~> 1.9.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = try(var.subscription_id, null)
  use_cli         = true
}
