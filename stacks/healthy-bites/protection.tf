# Protección y disponibilidad de la aplicación y de la API.
#
# - Firewall de Vercel (plan Hobby: hasta 3 reglas por proyecto, 1 de límite de peticiones). Lo que se rechaza aquí
#   no llega a ejecutar la función: no consume invocaciones, CPU ni conexiones de la base de datos.
# - Un Cloudflare Worker que mantiene caliente una instancia de la API (ADR 0011 de la API).

locals {
  # Peticiones por minuto y por IP antes de responder 429. Un uso normal hace unas pocas decenas.
  api_requests_per_minute = 300
  app_requests_per_minute = 600
}

resource "vercel_firewall_config" "api" {
  project_id = vercel_project.api.id
  enabled    = true

  rules {
    # Las rutas de la API empiezan por /api/v1/: los escáneres (/wp-admin, /.env, /phpmyadmin...) se quedan fuera.
    rule {
      name        = "Solo rutas de la API"
      description = "Rechaza en el borde lo que no empiece por /api/v1/."
      condition_group = [{
        conditions = [{ type = "path", op = "pre", value = "/api/v1/", neg = true }]
      }]
      action = { action = "deny" }
    }

    rule {
      name        = "Límite por IP"
      description = "Más de ${local.api_requests_per_minute} peticiones por minuto desde una IP: 429."
      condition_group = [{
        conditions = [{ type = "path", op = "pre", value = "/" }]
      }]
      action = {
        action = "rate_limit"
        rate_limit = {
          algo   = "fixed_window"
          window = 60
          limit  = local.api_requests_per_minute
          keys   = ["ip"]
          action = "rate_limit"
        }
      }
    }
  }
}

resource "vercel_firewall_config" "app" {
  project_id = vercel_project.app.id
  enabled    = true

  rules {
    rule {
      name        = "Límite por IP"
      description = "Más de ${local.app_requests_per_minute} peticiones por minuto desde una IP: 429."
      condition_group = [{
        conditions = [{ type = "path", op = "pre", value = "/" }]
      }]
      action = {
        action = "rate_limit"
        rate_limit = {
          algo   = "fixed_window"
          window = 60
          limit  = local.app_requests_per_minute
          keys   = ["ip"]
          action = "rate_limit"
        }
      }
    }
  }
}

# ---------------------------------------------------------------- instancia caliente

resource "cloudflare_workers_script" "api_keep_warm" {
  account_id         = var.cloudflare_account_id
  script_name        = "healthy-bites-api-keep-warm"
  content_file       = "${path.module}/workers/keep-warm.mjs"
  content_sha256     = filesha256("${path.module}/workers/keep-warm.mjs")
  main_module        = "keep-warm.mjs"
  compatibility_date = "2026-11-01"

  bindings = [{
    type = "plain_text"
    name = "PING_URL"
    text = "${local.api_url}/api/v1/actuator/health/liveness"
  }]

  observability = {
    enabled = true
  }
}

# Cada 4 minutos (Vercel apaga la instancia a los 5 sin tráfico). Los cron de Cloudflare son puntuales; los de
# GitHub Actions, que se probaron antes, pueden tardar más de una hora en arrancar.
resource "cloudflare_workers_cron_trigger" "api_keep_warm" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_workers_script.api_keep_warm.script_name
  schedules   = [{ cron = "*/4 * * * *" }]
}

# El Worker solo se ejecuta por cron: sin ruta pública en workers.dev ni previsualizaciones. Los cron exigen que la
# cuenta tenga un subdominio workers.dev (se crea una vez, al abrir «Workers & Pages» en el panel de Cloudflare).
resource "cloudflare_workers_script_subdomain" "api_keep_warm" {
  account_id       = var.cloudflare_account_id
  script_name      = cloudflare_workers_script.api_keep_warm.script_name
  enabled          = false
  previews_enabled = false
}
