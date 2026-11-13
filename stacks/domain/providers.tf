# CLOUDFLARE_API_TOKEN (de .env, ver scripts/load-env.*). Permisos mínimos: Zone → Zone → Read y Zone → DNS → Edit
# sobre la zona del dominio.
provider "cloudflare" {}
