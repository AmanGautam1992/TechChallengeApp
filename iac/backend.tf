terraform {
  backend "azurerm" {
  resource_group_name  = "#{tfStorageAccountRG}"
  storage_account_name = "#{tfStorageAccount}"
  container_name       = "terraform"
  key                  = "terraform.tfstate"
  access_key = "#{terraformStorageKey}"
   }
}