# Configure Terraform para usar os provedores necessários
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }
  }
}