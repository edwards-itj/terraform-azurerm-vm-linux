terraform {
  required_version = "~> 1.9.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = try(var.subscription_id, null)
  use_cli         = true
}
