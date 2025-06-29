# Resource Group para o State do Terraform (opcional, mas recomendado)
resource "azurerm_resource_group" "tfstate" {
  name     = "rg-terraform-state"
  location = "Brazil South"
  
  lifecycle {
    prevent_destroy = true  # Protege o RG que armazena seu state
  }
}

# Resource Group principal para sua aplicação
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.app_name}-${var.environment}"
  location = var.location
  
  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}