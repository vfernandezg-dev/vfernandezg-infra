# Sitio publicado en un subdominio: un CNAME desde <subdomain>.<zone> hacia su hosting.
resource "cloudflare_dns_record" "this" {
  zone_id = var.zone_id
  name    = "${var.subdomain}.${var.zone_name}"
  type    = "CNAME"
  content = var.target
  proxied = var.proxied
  ttl     = 1 # automático (Cloudflare lo exige cuando proxied = true)
  comment = var.comment
}
