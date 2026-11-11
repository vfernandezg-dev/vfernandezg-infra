# Healthy Bites · Infraestructura

[![Terraform](https://github.com/vfernandezg-dev/healthy-bites-infra/actions/workflows/terraform.yml/badge.svg)](https://github.com/vfernandezg-dev/healthy-bites-infra/actions/workflows/terraform.yml)
![Terraform](https://img.shields.io/badge/Terraform-1.15-844FBA?logo=terraform&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-DNS-F38020?logo=cloudflare&logoColor=white)

Infraestructura como código de **Healthy Bites** con Terraform. Forma parte del mismo sistema que
[healthy-bites-landing](https://github.com/vfernandezg-dev/healthy-bites-landing),
[healthy-web-app](https://github.com/vfernandezg-dev/healthy-web-app) y
[healthy-bites-api](https://github.com/vfernandezg-dev/healthy-bites-api).

## Qué gestiona

| Recurso                         | Detalle                                                          |
| ------------------------------- | ---------------------------------------------------------------- |
| `healthybites.vfernandezg.dev`  | `CNAME` → `vfernandezg-dev.github.io` (landing en GitHub Pages)  |

La zona `vfernandezg.dev` es compartida por todo el portafolio, así que este proyecto **solo la
lee** (`data "cloudflare_zone"`). Gestiona únicamente los registros que declara y nunca toca el resto
del dominio.

El registro de la landing va **sin proxy de Cloudflare** ("DNS only"), porque GitHub Pages tiene que
ver su propia IP para emitir el certificado HTTPS.

## Requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.9 o superior (el CI usa 1.15.8).
- Un **token de API de Cloudflare** limitado a la zona `vfernandezg.dev`, con estos permisos:
  - `Zone → Zone → Read`
  - `Zone → DNS → Edit`

El token se pasa **solo** como variable de entorno; no se escribe en ningún archivo.

## Uso

```bash
export CLOUDFLARE_API_TOKEN="…"   # PowerShell: $env:CLOUDFLARE_API_TOKEN = "…"

terraform init
terraform plan     # revisa los cambios
terraform apply    # los aplica tras confirmar
```

Las variables tienen valores por defecto en [`variables.tf`](variables.tf). Para cambiarlos, copia
[`terraform.tfvars.example`](terraform.tfvars.example) como `terraform.tfvars`, que Git ignora.

### Adoptar un registro creado a mano

Si un registro ya existe en Cloudflare, se incorpora sin recrearlo:

```bash
terraform import cloudflare_dns_record.landing <zone_id>/<record_id>
```

## State

Por ahora el *state* es **local** (`terraform.tfstate`, ignorado por Git). Cuando se automatice el
`apply` desde GitHub Actions, se migrará a un backend remoto, por ejemplo Cloudflare R2 o HCP
Terraform, con `terraform init -migrate-state`.

## CI

Cada pull request y cada push a `main` ejecutan [`terraform.yml`](.github/workflows/terraform.yml):
`terraform fmt -check` y `terraform validate`. El CI no usa credenciales ni aplica cambios.

## Próximos pasos

- Registros de `app.healthybites` (aplicación web) y `api.healthybites` (API).
- Proyectos de Vercel con el provider [`vercel/vercel`](https://registry.terraform.io/providers/vercel/vercel).
- Base de datos en Neon con el provider comunitario [`kislerdm/neon`](https://registry.terraform.io/providers/kislerdm/neon).
- Backend remoto para el *state* y `plan`/`apply` desde GitHub Actions.
