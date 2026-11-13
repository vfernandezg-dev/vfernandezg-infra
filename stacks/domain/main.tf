# Configuración del dominio vfernandezg.dev en sí, no de un proyecto. Es la única stack que puede tocar registros de
# todo el dominio (ver README de la raíz); las de proyecto solo leen la zona.

data "cloudflare_zone" "main" {
  filter = {
    name = var.zone_name
  }
}

# GitHub Pages: dominio verificado en la cuenta de GitHub. Así nadie más puede publicar un sitio de Pages en
# vfernandezg.dev ni en sus subdominios directos (por ejemplo, si un CNAME siguiera apuntando a Pages sin sitio detrás).
# El registro tiene que quedarse: si se borra, el dominio deja de estar verificado. El valor lo da GitHub en
# Settings → Pages → Add a domain; no es secreto.
resource "cloudflare_dns_record" "github_pages_challenge" {
  zone_id = data.cloudflare_zone.main.id
  name    = "_github-pages-challenge-${var.github_owner}.${var.zone_name}"
  type    = "TXT"
  content = "\"b632e51a7b9f893e33c959fa7ec524\""
  ttl     = 1
  comment = "GitHub Pages · verificación del dominio (vfernandezg-infra/stacks/domain)"
}
