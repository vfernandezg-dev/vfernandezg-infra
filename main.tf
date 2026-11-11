# La zona (vfernandezg.dev) es compartida por todo el portafolio: aquí solo se consulta.
# Este proyecto gestiona únicamente los registros que declara, nunca el resto de la zona.
data "cloudflare_zone" "main" {
  filter = {
    name = var.zone_name
  }
}

locals {
  zone_id      = data.cloudflare_zone.main.id
  landing_fqdn = "${var.landing_subdomain}.${var.zone_name}"
}
