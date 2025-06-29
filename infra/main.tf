terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-appservice-python"
  location = "Brazil South"
}

# Banco de dados PostgreSQL no Azure
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "pgserver-${random_id.server.hex}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "14"
  administrator_login    = var.db_username
  administrator_password = var.db_password
  storage_mb            = 32768
  sku_name              = "B_Standard_B1ms"
  zone                  = "1"
}

resource "azurerm_postgresql_flexible_server_database" "appdb" {
  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
  collation = "pt_BR.utf8"
}

# App Service
resource "azurerm_linux_web_app" "app" {
  name                = "app-python-${random_id.app.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      python_version = "3.10"
    }
    always_on = true
  }

  app_settings = {
    "DATABASE_URL" = "postgresql://${var.db_username}:${var.db_password}@${azurerm_postgresql_flexible_server.db.fqdn}:5432/${azurerm_postgresql_flexible_server_database.appdb.name}?sslmode=require"
    "WEBSITES_PORT" = "5000"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITES_PORT"],
    ]
  }
}

resource "azurerm_service_plan" "plan" {
  name                = "plan-appservice-python"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "random_id" "server" {
  byte_length = 4
}

resource "random_id" "app" {
  byte_length = 4
}