variable "zone_name" {
  description = "Dominio raíz en Cloudflare. Esta stack solo lo lee: la zona se configura en la stack \"domain\"."
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
