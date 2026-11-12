# Los tokens se leen de variables de entorno y nunca se escriben en archivos del repositorio
# (en local, desde el .env.local de la raíz, ignorado por git; ver .env.local.example).

# CLOUDFLARE_API_TOKEN. Permisos mínimos: Zone → Zone → Read y Zone → DNS → Edit sobre la zona del
# dominio, y Account → Workers R2 Storage → Edit para el bucket de ficheros.
provider "cloudflare" {}

# VERCEL_API_TOKEN, con el alcance de la cuenta personal.
provider "vercel" {}

# NEON_API_KEY.
provider "neon" {}

provider "random" {}
