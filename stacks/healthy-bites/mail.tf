# Correo saliente con Resend desde el dominio (Email Routing de Cloudflare solo recibe y reenvía).
# Resend envía con Amazon SES desde el subdominio "send": su MX y su SPF van ahí y no tocan los MX del dominio raíz
# (Email Routing). La firma DKIM autentica los correos de @vfernandezg.dev.
# Son registros del dominio: cuando exista la stack "domain", pasan a ella.
# Valores de Resend para el dominio (id 909f93ff-25da-46d2-8ba9-52b483a35428, región us-east-1). El DKIM es una clave
# pública: ya es visible en el DNS.

locals {
  resend_dkim = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDkyLpR99gyYpx2y7b2nbDI5c8XoCUrJH0dF+3m81Iotuj4Dr5GN49RHY1pto9lTGqMAmX6XQmxtRqsm28cLfhpeNrfFZnVuz+hCun04sCgUD8Wd1ucc+RAjkq0528Dsn0AK7gPGw2U4xRxXFYh1JCL0sC7xNsQ/BUXPmm/RxdMFwIDAQAB"
}

resource "cloudflare_dns_record" "resend_dkim" {
  zone_id = data.cloudflare_zone.main.id
  name    = "resend._domainkey.${var.zone_name}"
  type    = "TXT"
  content = "\"${local.resend_dkim}\""
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

resource "cloudflare_dns_record" "resend_tracking" {
  zone_id = data.cloudflare_zone.main.id
  name    = "rsend.${var.zone_name}"
  type    = "CNAME"
  content = "send.forge.rmta.net"
  proxied = false
  ttl     = 1
  comment = "Resend · ruta de envío (vfernandezg-infra/stacks/healthy-bites)"
}
