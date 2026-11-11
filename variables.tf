variable "zone_name" {
  description = "Dominio raíz administrado en Cloudflare. Este proyecto solo lo lee: no gestiona la zona completa."
  type        = string
  default     = "vfernandezg.dev"
}

variable "landing_subdomain" {
  description = "Subdominio de la landing page de Healthy Bites."
  type        = string
  default     = "healthybites"
}

variable "github_pages_host" {
  description = "Host de GitHub Pages donde se publica la landing."
  type        = string
  default     = "vfernandezg-dev.github.io"
}
