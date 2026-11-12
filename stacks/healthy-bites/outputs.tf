output "landing_url" {
  description = "URL pública de la landing."
  value       = module.landing.url
}

output "landing_record_id" {
  description = "ID del registro DNS de la landing en Cloudflare."
  value       = module.landing.record_id
}

output "app_url" {
  description = "URL pública de la aplicación web."
  value       = module.app.url
}

output "api_url" {
  description = "URL pública de la API."
  value       = module.api.url
}

output "vercel_app_project_id" {
  description = "Proyecto de Vercel de la web (VERCEL_PROJECT_ID para la CLI)."
  value       = vercel_project.app.id
}

output "vercel_api_project_id" {
  description = "Proyecto de Vercel de la API (VERCEL_PROJECT_ID para la CLI)."
  value       = vercel_project.api.id
}

output "neon_host" {
  description = "Host de Postgres en Neon (conexión directa)."
  value       = neon_project.healthy_bites.database_host
}

output "media_bucket" {
  description = "Bucket R2 de los ficheros subidos."
  value       = cloudflare_r2_bucket.media.name
}
