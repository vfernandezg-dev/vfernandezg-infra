output "landing_url" {
  description = "URL pública de la landing."
  value       = module.landing.url
}

output "landing_record_id" {
  description = "ID del registro DNS de la landing en Cloudflare."
  value       = module.landing.record_id
}
