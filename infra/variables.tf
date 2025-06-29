variable "app_name" {
  description = "Nome da aplicação"
  type        = string
  default     = "api-python"
}

variable "environment" {
  description = "Ambiente (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Região Azure"
  type        = string
  default     = "Brazil South"
}