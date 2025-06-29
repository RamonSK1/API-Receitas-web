resource "random_password" "postgres_password" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "pgserver-${var.project_name}-${var.environment}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = "14"  # Versão mais estável
  administrator_login    = var.db_username
  administrator_password = random_password.postgres_password.result
  storage_mb            = 32768  # 32GB
  sku_name              = "B_Standard_B1ms"  # Básico para dev, altere para produção
  zone                  = "1"    # Zona de disponibilidade

  maintenance_window {
    day_of_week  = 0  # Domingo
    start_hour   = 2  # 2AM
    start_minute = 0
  }

  backup {
    retention_days = 7  # Mantém backups por 7 dias
  }

  lifecycle {
    ignore_changes = [
      zone,  # Pode ser ajustado automaticamente pela Azure
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "app_db" {
  name      = "${var.project_name}_${var.environment}"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "pt_BR.utf8"  # Collation para português
  charset   = "utf8"
}

# Configuração de firewall para permitir conexões
resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"  # Permite todos os IPs (restrinja em produção)
}

# Configuração de conexão segura
resource "azurerm_postgresql_flexible_server_configuration" "ssl_enforcement" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "on"  # Força SSL
}

# Outputs para uso em outros módulos
output "postgres_hostname" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgres_connection_string" {
  value = "postgresql://${var.db_username}:${random_password.postgres_password.result}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.app_db.name}?sslmode=require"
  sensitive = true
}
