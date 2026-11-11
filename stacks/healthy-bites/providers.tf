# El token se lee de la variable de entorno CLOUDFLARE_API_TOKEN.
# Nunca se escribe en archivos del repositorio.
# Permisos mínimos: Zone → Zone → Read y Zone → DNS → Edit, solo sobre la zona del dominio.
provider "cloudflare" {}
