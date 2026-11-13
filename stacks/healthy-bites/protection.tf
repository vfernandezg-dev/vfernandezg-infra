# Protección de la aplicación y de la API.
#
# Firewall de Vercel (plan Hobby: hasta 3 reglas por proyecto, 1 de límite de peticiones). Lo que se rechaza aquí no
# llega a ejecutar la función: no consume invocaciones, CPU ni conexiones de la base de datos. La instancia caliente
# de la API la mantiene un workflow programado (.github/workflows/healthy-bites-keep-warm.yml).

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
