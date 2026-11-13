variable "zone_name" {
  description = "Dominio principal (zona de Cloudflare)."
  type        = string
  default     = "vfernandezg.dev"
}

variable "github_owner" {
  description = "Cuenta de GitHub que publica los sitios de GitHub Pages del dominio."
  type        = string
  default     = "vfernandezg-dev"
}
