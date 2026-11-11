variable "zone_id" {
  description = "ID de la zona de Cloudflare donde se crea el registro."
  type        = string
}

variable "zone_name" {
  description = "Nombre de la zona (p. ej. vfernandezg.dev). Se usa para construir el FQDN."
  type        = string
}

variable "subdomain" {
  description = "Subdominio del sitio, sin la zona (p. ej. \"healthybites\" o \"app.healthybites\")."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$", var.subdomain))
    error_message = "El subdominio solo admite letras minúsculas, números, guiones y puntos entre etiquetas."
  }
}

variable "target" {
  description = "Host de destino del CNAME (p. ej. usuario.github.io o cname.vercel-dns.com)."
  type        = string
}

variable "proxied" {
  description = "Activar el proxy de Cloudflare. Debe ser false si el hosting emite su propio certificado (GitHub Pages, Vercel)."
  type        = bool
  default     = false
}

variable "comment" {
  description = "Nota visible en el panel de Cloudflare."
  type        = string
  default     = "Gestionado con Terraform (vfernandezg-infra)"
}
