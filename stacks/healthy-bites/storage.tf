# Ficheros subidos por los usuarios. Vercel no tiene disco persistente: la API los guarda en R2 (API S3) y sirve
# enlaces firmados de vida corta, así que el bucket es privado.
resource "cloudflare_r2_bucket" "media" {
  account_id = var.cloudflare_account_id
  name       = var.media_bucket
  location   = "enam"
}

# Subidas directas: el navegador sube el fichero al bucket con una URL prefirmada que pide a la API (así no pasa por
# Vercel, que corta las peticiones de más de 4,5 MB). Solo PUT desde la aplicación; las lecturas son enlaces firmados
# que no necesitan CORS.
resource "cloudflare_r2_bucket_cors" "media" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.media.name

  rules = [{
    allowed = {
      origins = [local.app_url]
      methods = ["PUT"]
      headers = ["content-type"]
    }
    max_age_seconds = 3600
  }]
}

# Ciclo de vida: las subidas directas esperan con el prefijo «pending-» hasta que la API las confirma; las que nadie
# confirma se borran al día. Se mantiene la regla por defecto de R2 para las subidas multiparte a medias.
# Las reglas van en el orden en que las devuelve Cloudflare (la regla por defecto primero).
resource "cloudflare_r2_bucket_lifecycle" "media" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.media.name

  rules = [
    {
      id         = "Default Multipart Abort Rule"
      enabled    = true
      conditions = { prefix = "" }
      abort_multipart_uploads_transition = {
        condition = { type = "Age", max_age = 604800 }
      }
    },
    {
      id         = "subidas-sin-confirmar"
      enabled    = true
      conditions = { prefix = "pending-" }
      delete_objects_transition = {
        condition = { type = "Age", max_age = 86400 }
      }
    },
  ]

  # El proveedor (5.29) lee cada regla con la transición que no tiene como un objeto vacío y cada plan propondría
  # «quitarlo». Las reglas reales son exactamente estas (GET .../r2/buckets/<bucket>/lifecycle). Para cambiarlas:
  # terraform plan -replace=cloudflare_r2_bucket_lifecycle.media -out stack.tfplan (sustituye todas las reglas).
  lifecycle {
    ignore_changes = [rules]
  }
}
