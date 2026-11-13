# Stack `healthy-bites`

Infraestructura de [Healthy Bites](https://healthybites.vfernandezg.dev): la landing, la aplicación web, la API,
la base de datos, los ficheros y el correo saliente.

| Pieza | Dónde | Recursos |
| --- | --- | --- |
| Landing | GitHub Pages | CNAME `healthybites` ([`main.tf`](main.tf)) |
| Aplicación web (Angular) | Vercel, proyecto `healthy-bites-app` | Proyecto, variables `NG_APP_*` y dominio `app-healthybites` ([`hosting.tf`](hosting.tf)) |
| API (Spring Boot) | Vercel, proyecto `healthy-bites-api` (Container runtime, `iad1`) | Proyecto, variables de entorno, secreto JWT y dominio `api-healthybites` ([`hosting.tf`](hosting.tf)) |
| Base de datos | Neon, PostgreSQL 18 en `aws-us-east-1` | Proyecto, base y rol `healthybites` ([`database.tf`](database.tf)) |
| Ficheros subidos | Cloudflare R2, bucket privado `healthy-bites-media` | Bucket ([`storage.tf`](storage.tf)) |
| Correo saliente | Resend, desde `projects@vfernandezg.dev` | DKIM, SPF, MX de rebotes y dominio de seguimiento ([`mail.tf`](mail.tf)) |
| DNS | Cloudflare, zona `vfernandezg.dev` | CNAME de `app-healthybites` y `api-healthybites` hacia Vercel ([`dns.tf`](dns.tf)) |

Terraform gestiona la configuración. Los despliegues del código los hace la CLI de Vercel (ver abajo).

## Credenciales

Todas viven en `.env`, en la raíz del repo e ignorado por git. [`.env.example`](../../.env.example) explica de
dónde sale cada una. Para cargarlas en la sesión, desde la raíz del repo:

```powershell
. .\scripts\load-env.ps1      # PowerShell
```

```bash
source scripts/load-env.sh    # bash
```

El _state_ local (`terraform.tfstate`, ignorado) contiene secretos: la contraseña de la base de datos y el
secreto de los JWT. No se comparte ni se sube.

## Infraestructura

```powershell
cd stacks\healthy-bites
terraform init
terraform plan -out hosting.tfplan   # revisa el plan
terraform apply hosting.tfplan
Remove-Item hosting.tfplan
```

El dominio de Resend se crea una vez desde su panel (o su API) y se verifica cuando los registros de
[`mail.tf`](mail.tf) están publicados. Si Resend rota la clave DKIM, se actualiza `local.resend_dkim`.

## Despliegue del código

Los dos proyectos se despliegan con la CLI de Vercel. `VERCEL_ORG_ID` y `VERCEL_PROJECT_ID` sustituyen a la
carpeta `.vercel` de `vercel link`, así que no queda nada en los repositorios. Los ids salen de
`terraform output`.

**API.** Se sube una copia limpia de `main` (`git archive`: sin `.env`, `mediafiles/` ni `target/`). Vercel
construye el `Dockerfile` y lo ejecuta como función.

```powershell
git -C <ruta de healthy-bites-api> archive --format=tar -o $env:TEMP\api.tar main
New-Item -ItemType Directory -Force $env:TEMP\api-deploy | Out-Null
tar -xf $env:TEMP\api.tar -C $env:TEMP\api-deploy
Set-Location $env:TEMP\api-deploy
$env:VERCEL_ORG_ID = $env:VERCEL_TEAM_ID
$env:VERCEL_PROJECT_ID = terraform -chdir=<ruta de la stack> output -raw vercel_api_project_id
pnpm dlx vercel deploy --prod --yes --token $env:VERCEL_API_TOKEN
```

La primera petición tras el despliegue arranca la API, y Flyway aplica las migraciones en Neon.

**Aplicación web.** Se construye en local y se sube el resultado (`--prebuilt`). La clave de PrimeNG es una
variable `sensitive` en Vercel y `vercel pull` no la devuelve, así que se toma de `.env`.

```powershell
# En una copia limpia de main de healthy-web-app, con las dependencias instaladas (pnpm install --frozen-lockfile)
$env:VERCEL_ORG_ID = $env:VERCEL_TEAM_ID
$env:VERCEL_PROJECT_ID = terraform -chdir=<ruta de la stack> output -raw vercel_app_project_id
pnpm dlx vercel pull --yes --environment=production --token $env:VERCEL_API_TOKEN
(Get-Content .vercel\.env.production.local) -notmatch '^NG_APP_PRIMENG_LICENSE_KEY=' | Set-Content .vercel\.env.production.local
pnpm dlx vercel build --prod --token $env:VERCEL_API_TOKEN
pnpm dlx vercel deploy --prebuilt --prod --token $env:VERCEL_API_TOKEN
```

`pnpm build` comprueba después de compilar que las variables `NG_APP_*` quedaron dentro del bundle.

## Límites conocidos (plan gratuito)

- **Peticiones de 4,5 MB como máximo** en las funciones de Vercel: las subidas más grandes fallan.
- **Arranque en frío** de unos 12 a 25 s en la primera petición tras unos minutos sin tráfico (JVM más Flyway).
- **Tareas programadas** (`@Scheduled`) solo mientras hay una instancia activa. El acceso de pago sigue siendo
  correcto, porque se compara con la fecha actual en cada petición.
- **Neon**: 6 horas de historial para restaurar a un punto en el tiempo.
- Algunos operadores españoles bloquean de forma temporal rangos de IP de Vercel. Mientras dura el bloqueo,
  la app y la API no responden desde esas redes (`curl` falla con el error 35, "connection reset").
