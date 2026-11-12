# Postgres gestionado en Neon, en la misma zona que las funciones de Vercel (iad1 ↔ aws-us-east-1).
# La API aplica sus migraciones (Flyway) al arrancar; aquí solo se crean el proyecto, la base y el rol.
resource "neon_project" "healthy_bites" {
  name       = "healthy-bites"
  region_id  = "aws-us-east-1"
  pg_version = 17
  org_id     = var.neon_org_id != "" ? var.neon_org_id : null
  # El plan gratuito de Neon permite como mucho 6 horas de historial (restaurar a un punto en el tiempo).
  history_retention_seconds = 21600

  branch {
    name          = "main"
    database_name = "healthybites"
    role_name     = "healthybites"
  }
}

locals {
  # Conexión directa (sin el pooler): Flyway usa bloqueos de sesión que PgBouncer en modo transacción no admite.
  db_url = "jdbc:postgresql://${neon_project.healthy_bites.database_host}/${neon_project.healthy_bites.database_name}?sslmode=require"
}
