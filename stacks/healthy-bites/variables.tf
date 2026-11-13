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

# ---------------------------------------------------------------- app y API

variable "app_subdomain" {
  description = "Subdominio de la aplicación web (Angular, en Vercel)."
  type        = string
  default     = "app-healthybites"
}

variable "api_subdomain" {
  description = "Subdominio de la API (Spring Boot en un contenedor de Vercel)."
  type        = string
  default     = "api-healthybites"
}

variable "vercel_cname" {
  description = "Destino CNAME de los dominios propios en Vercel."
  type        = string
  default     = "cname.vercel-dns.com"
}

variable "vercel_region" {
  description = "Región de las funciones de Vercel. iad1 (Washington) está junto a Neon aws-us-east-1."
  type        = string
  default     = "iad1"
}

variable "cloudflare_account_id" {
  description = "Cuenta de Cloudflare donde vive el bucket R2 (TF_VAR_cloudflare_account_id)."
  type        = string
}

variable "vercel_team_id" {
  description = "Equipo de Vercel de la cuenta (TF_VAR_vercel_team_id). No es un secreto."
  type        = string
}

variable "neon_org_id" {
  description = "Organización de Neon, si la cuenta pertenece a una (TF_VAR_neon_org_id). Vacío: la personal."
  type        = string
  default     = ""
}

variable "media_bucket" {
  description = "Bucket R2 de los ficheros subidos (imágenes, PDF y vídeos)."
  type        = string
  default     = "healthy-bites-media"
}

# ---------------------------------------------------------------- secretos (TF_VAR_*, nunca en tfvars versionados)

variable "r2_access_key_id" {
  description = "Access Key ID S3 del token de R2 (lectura y escritura del bucket)."
  type        = string
  sensitive   = true
}

variable "r2_secret_access_key" {
  description = "Secret Access Key S3 del token de R2."
  type        = string
  sensitive   = true
}

variable "resend_smtp_key" {
  description = "API key de Resend solo para envío, limitada al dominio: es la contraseña SMTP de la API."
  type        = string
  sensitive   = true
}

variable "mail_from" {
  description = "Remitente de los correos de la API (dirección del dominio verificado en Resend)."
  type        = string
  default     = "Healthy Bites <projects@vfernandezg.dev>"
}

variable "paypal_client_id" {
  description = "Client ID de PayPal (sandbox mientras el proyecto sea de portafolio)."
  type        = string
  sensitive   = true
}

variable "paypal_client_secret" {
  description = "Client secret de PayPal."
  type        = string
  sensitive   = true
}

variable "paypal_api_base" {
  description = "API de PayPal. Solo el entorno de pruebas: Healthy Bites es un proyecto académico y sus políticas dicen que nunca se cobra dinero real."
  type        = string
  default     = "https://api-m.sandbox.paypal.com"

  validation {
    condition     = var.paypal_api_base == "https://api-m.sandbox.paypal.com"
    error_message = "Healthy Bites solo usa el sandbox de PayPal (no hay cobros reales). Cambiarlo exige revisar antes /privacidad y /seguridad."
  }
}

variable "contact_recipient" {
  description = "Buzón que recibe el formulario de contacto de la landing."
  type        = string
  default     = "projects@vfernandezg.dev"
}

variable "primeng_license_key" {
  description = "Clave de la licencia Community de PrimeNG (caduca cada 12 meses)."
  type        = string
  sensitive   = true
}
