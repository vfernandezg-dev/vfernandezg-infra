output "landing_url" {
  description = "URL pública de la landing."
  value       = "https://${local.landing_fqdn}"
}

output "landing_dns_record" {
  description = "Registro DNS de la landing."
  value       = "${cloudflare_dns_record.landing.name} CNAME ${cloudflare_dns_record.landing.content} (proxied = ${cloudflare_dns_record.landing.proxied})"
}
