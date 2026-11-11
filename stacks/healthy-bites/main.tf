# La zona (vfernandezg.dev) es compartida por todo el portafolio: esta stack solo la consulta.
# Gestiona únicamente los registros de Healthy Bites, nunca el resto de la zona.
data "cloudflare_zone" "main" {
  filter = {
    name = var.zone_name
  }
}
