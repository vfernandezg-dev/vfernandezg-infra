# Correo saliente con Resend desde el dominio (Email Routing de Cloudflare solo recibe y reenvía).
# Resend envía con Amazon SES desde el subdominio "send": su MX y su SPF van ahí y no tocan los MX del dominio raíz
# (Email Routing). La firma DKIM autentica los correos de @vfernandezg.dev.
# Son registros del dominio: cuando exista la stack "domain", pasan a ella.

resource "cloudflare_dns_record" "resend_dkim" {
  zone_id = data.cloudflare_zone.main.id
  name    = "resend._domainkey.${var.zone_name}"
  type    = "TXT"
  content = var.resend_dkim
  ttl     = 1
  comment = "Resend · DKIM (vfernandezg-infra/stacks/healthy-bites)"
}

resource "cloudflare_dns_record" "resend_return_path_mx" {
  zone_id  = data.cloudflare_zone.main.id
  name     = "send.${var.zone_name}"
  type     = "MX"
  content  = "feedback-smtp.us-east-1.amazonses.com"
  priority = 10
  ttl      = 1
  comment  = "Resend · rebotes (vfernandezg-infra/stacks/healthy-bites)"
}

resource "cloudflare_dns_record" "resend_return_path_spf" {
  zone_id = data.cloudflare_zone.main.id
  name    = "send.${var.zone_name}"
  type    = "TXT"
  content = "\"v=spf1 include:amazonses.com ~all\""
  ttl     = 1
  comment = "Resend · SPF del remitente del sobre (vfernandezg-infra/stacks/healthy-bites)"
}
