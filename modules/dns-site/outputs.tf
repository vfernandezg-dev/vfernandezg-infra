output "fqdn" {
  description = "Nombre completo del sitio."
  value       = cloudflare_dns_record.this.name
}

output "url" {
  description = "URL HTTPS del sitio."
  value       = "https://${cloudflare_dns_record.this.name}"
}

output "record_id" {
  description = "ID del registro en Cloudflare (útil para terraform import)."
  value       = cloudflare_dns_record.this.id
}
