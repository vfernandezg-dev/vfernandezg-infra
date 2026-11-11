# Landing page → GitHub Pages.
# Sin proxy de Cloudflare ("DNS only"): GitHub Pages debe ver su propia IP para emitir el
# certificado HTTPS del dominio propio.
module "landing" {
  source = "../../modules/dns-site"

  zone_id   = data.cloudflare_zone.main.id
  zone_name = var.zone_name
  subdomain = var.landing_subdomain
  target    = var.github_pages_host
  proxied   = false
  comment   = "Healthy Bites · landing en GitHub Pages (vfernandezg-infra/stacks/healthy-bites)"
}
