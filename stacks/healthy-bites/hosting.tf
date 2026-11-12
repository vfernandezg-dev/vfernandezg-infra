# Aplicación web (Angular) y API (Spring Boot en contenedor) en Vercel, cada una con su dominio propio.
# Los despliegues los hace la CLI de Vercel (ver README de la stack); aquí se gestiona la configuración.

locals {
  app_url = "https://${var.app_subdomain}.${var.zone_name}"
  api_url = "https://${var.api_subdomain}.${var.zone_name}"
}

# Secreto de firma de los JWT y de los enlaces de ficheros: 64 bytes en Base64 (HS512). Vive solo en el state.
resource "random_bytes" "jwt_secret" {
  length = 64
}

# ---------------------------------------------------------------- web

resource "vercel_project" "app" {
  name         = "healthy-bites-app"
  node_version = "26.x"

  resource_config = {
    function_default_regions = [var.vercel_region]
  }
}

resource "vercel_project_environment_variables" "app" {
  project_id = vercel_project.app.id
  variables = [
    {
      key       = "NG_APP_API_URL"
      value     = "${local.api_url}/api/v1"
      target    = ["production", "preview"]
      sensitive = false
    },
    {
      key       = "NG_APP_LANDING_URL"
      value     = "https://${var.landing_subdomain}.${var.zone_name}"
      target    = ["production", "preview"]
      sensitive = false
    },
    {
      key       = "NG_APP_PRIMENG_LICENSE_KEY"
      value     = var.primeng_license_key
      target    = ["production", "preview"]
      sensitive = true
    },
  ]
}

resource "vercel_project_domain" "app" {
  project_id = vercel_project.app.id
  domain     = "${var.app_subdomain}.${var.zone_name}"
}

# ---------------------------------------------------------------- API

resource "vercel_project" "api" {
  name = "healthy-bites-api"
  # El Dockerfile de la raíz se construye y se ejecuta como función (Container runtime, beta).
  framework = "container"

  resource_config = {
    fluid                    = true
    function_default_regions = [var.vercel_region]
  }
}

resource "vercel_project_environment_variables" "api" {
  project_id = vercel_project.api.id
  variables = [
    for key, value in {
      SPRING_PROFILES_ACTIVE = "prod"
      # El contenedor escucha en 8090 (Dockerfile); Vercel enruta al puerto de PORT.
      PORT                 = "8090"
      DB_URL               = local.db_url
      DB_USERNAME          = neon_project.healthy_bites.database_user
      DB_PASSWORD          = neon_project.healthy_bites.database_password
      DB_POOL_SIZE         = "4"
      JWT_SECRET           = random_bytes.jwt_secret.base64
      APP_FRONTEND_URL     = local.app_url
      API_PUBLIC_URL       = "${local.api_url}/api/v1"
      CORS_APP_ORIGINS     = local.app_url
      CORS_LANDING_ORIGINS = "https://${var.landing_subdomain}.${var.zone_name}"
      CONTACT_RECIPIENT    = var.contact_recipient
      MAIL_USERNAME        = var.mail_username
      MAIL_PASSWORD        = var.mail_password
      PAYPAL_CLIENT_ID     = var.paypal_client_id
      PAYPAL_CLIENT_SECRET = var.paypal_client_secret
      PAYPAL_API_BASE      = var.paypal_api_base
      STORAGE_TYPE         = "s3"
      S3_ENDPOINT          = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
      S3_BUCKET            = cloudflare_r2_bucket.media.name
      S3_ACCESS_KEY        = var.r2_access_key_id
      S3_SECRET_KEY        = var.r2_secret_access_key
      S3_REGION            = "auto"
      S3_PATH_STYLE        = "true"
      } : {
      key       = key
      value     = value
      target    = ["production"]
      sensitive = contains(["DB_PASSWORD", "JWT_SECRET", "MAIL_PASSWORD", "PAYPAL_CLIENT_SECRET", "S3_SECRET_KEY", "S3_ACCESS_KEY"], key)
    }
  ]
}

resource "vercel_project_domain" "api" {
  project_id = vercel_project.api.id
  domain     = "${var.api_subdomain}.${var.zone_name}"
}
