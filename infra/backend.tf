terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate${lower(random_id.sa_suffix.hex)}"  
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"  
  }
}
