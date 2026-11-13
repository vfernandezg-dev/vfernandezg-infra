# Ficheros subidos por los usuarios. Vercel no tiene disco persistente: la API los guarda en R2 (API S3) y sirve
# enlaces firmados de vida corta, así que el bucket es privado.
resource "cloudflare_r2_bucket" "media" {
  account_id = var.cloudflare_account_id
  name       = var.media_bucket
  location   = "enam"
}
