variable "project_name" {
  description = "Nome do projeto (usado para nomear recursos)"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Ambiente (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "db_username" {
  description = "Nome do usuário administrador do PostgreSQL"
  type        = string
  default     = "pgadmin"
}

variable "db_password" {
  description = "Senha do administrador (sobrescrita pelo random_password)"
  type        = string
  sensitive   = true
  default     = ""  # Será gerada automaticamente
}
