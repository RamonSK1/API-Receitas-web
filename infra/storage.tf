# storage.tf - Criação da Storage Account para o State do Terraform

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-terraform-state"
  location = "Brazil South"  # Altere para sua região preferencial
  
  tags = {
    purpose = "Armazenamento do State do Terraform"
    environment = "global"
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "sttfstate${lower(random_id.sa_suffix.hex)}"  # Nome deve ser único globalmente
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "GRS"  # Geo-redundante para maior segurança
  
  identity {
    type = "SystemAssigned"
  }

  blob_properties {
    versioning_enabled = true  # Importante para recuperação de versões
    container_delete_retention_policy {
      days = 30  # Mantém backups de containers apagados
    }
  }

  tags = {
    environment = "infra"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

resource "random_id" "sa_suffix" {
  byte_length = 4
}

# Outputs para uso no backend.tf
output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
  sensitive = true
}

output "storage_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "storage_account_key" {
  value = azurerm_storage_account.tfstate.primary_access_key
  sensitive = true
}