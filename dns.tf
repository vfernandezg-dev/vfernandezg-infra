# Landing page → GitHub Pages.
# Sin proxy de Cloudflare ("DNS only"): GitHub Pages debe ver su propia IP para emitir el
# certificado HTTPS del dominio propio. Con el proxy activo, la emisión falla.
resource "cloudflare_dns_record" "landing" {
  zone_id = local.zone_id
  name    = local.landing_fqdn
  type    = "CNAME"
  content = var.github_pages_host
  proxied = false
  ttl     = 1 # automático
  comment = "Healthy Bites · landing en GitHub Pages (gestionado con Terraform: healthy-bites-infra)"
}
