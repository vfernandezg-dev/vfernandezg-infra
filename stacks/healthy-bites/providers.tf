# Los tokens se leen de variables de entorno y nunca se escriben en archivos del repositorio
# (en local, desde el .env.local de la raíz, ignorado por git; ver .env.local.example).

# CLOUDFLARE_API_TOKEN. Permisos mínimos: Zone → Zone → Read y Zone → DNS → Edit sobre la zona del
# dominio, Account → Workers R2 Storage → Edit para el bucket de ficheros y Account → Workers Scripts → Edit para
# el Worker que mantiene caliente la API (protection.tf).
provider "cloudflare" {}

# VERCEL_API_TOKEN, con el alcance de la cuenta personal. El equipo (team_…) es el de la cuenta: sin él, el
# provider guarda los proyectos sin equipo y luego no los reconoce al leerlos.
provider "vercel" {
  team = var.vercel_team_id
}

# NEON_API_KEY.
provider "neon" {}

provider "random" {}
