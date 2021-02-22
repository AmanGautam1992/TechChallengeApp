terraform {
  backend "azurerm" {
  resource_group_name  = "__tfStorageAccountRG__"
  storage_account_name = "__tfStorageAccount__"
  container_name       = "terraform"
  key                  = "terraform.tfstate"
   }
}