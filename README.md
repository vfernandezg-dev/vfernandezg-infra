# vfernandezg-infra

[![Terraform](https://github.com/vfernandezg-dev/vfernandezg-infra/actions/workflows/terraform.yml/badge.svg)](https://github.com/vfernandezg-dev/vfernandezg-infra/actions/workflows/terraform.yml)
![Terraform](https://img.shields.io/badge/Terraform-1.15-844FBA?logo=terraform&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-DNS-F38020?logo=cloudflare&logoColor=white)

Infraestructura como código de **vfernandezg.dev** y de los proyectos de mi portafolio, con Terraform.

## Principios

- **Una stack por proyecto, cada una con su propio _state_.** Un `apply` de un proyecto nunca puede
  afectar a otro.
- **La zona se configura en un solo lugar.** Solo la stack `domain` gestiona la zona
  `vfernandezg.dev` (DNSSEC, correo, raíz del portafolio). Las stacks de proyectos solo la _leen_ y
  crean sus propios subdominios.
- **Módulos reutilizables.** Un proyecto nuevo compone piezas de [`modules/`](modules) en lugar de
  repetir código.
- **Sin secretos en el repositorio.** Los tokens se pasan como variables de entorno y el _state_ no se
  versiona.

## Estructura

```
.
├── modules/
│   └── dns-site/          # Sitio en un subdominio: CNAME hacia su hosting
└── stacks/
    └── healthy-bites/     # Healthy Bites: landing (y luego app, API, Vercel y Neon)
```

## Stacks

| Stack                                     | Gestiona                                                           |
| ----------------------------------------- | ------------------------------------------------------------------ |
| [`healthy-bites`](stacks/healthy-bites)   | `healthybites.vfernandezg.dev` → GitHub Pages (landing, DNS only)  |

## Uso

Requisitos: [Terraform](https://developer.hashicorp.com/terraform/install) 1.9 o superior (el CI usa
1.15.8) y un token de API de Cloudflare limitado a la zona `vfernandezg.dev`, con
`Zone → Zone → Read` y `Zone → DNS → Edit`.

```bash
cd stacks/healthy-bites
export CLOUDFLARE_API_TOKEN="…"   # PowerShell: $env:CLOUDFLARE_API_TOKEN = "…"

terraform init
terraform plan     # revisa los cambios
terraform apply    # los aplica tras confirmar
```

Si un recurso ya existe en Cloudflare, se adopta sin recrearlo con `terraform import`. Por ejemplo:
`terraform import module.landing.cloudflare_dns_record.this <zone_id>/<record_id>`.

### Añadir un proyecto

1. Crea `stacks/<proyecto>/` con `versions.tf`, `providers.tf` y la consulta de la zona.
2. Declara sus sitios con el módulo [`dns-site`](modules/dns-site).
3. Ejecuta `terraform init` y genera el lockfile para todas las plataformas:
   `terraform providers lock -platform=linux_amd64 -platform=windows_amd64 -platform=darwin_arm64 -platform=darwin_amd64`.

El CI detecta la nueva stack automáticamente.

## State

Por ahora cada stack guarda su _state_ en local (`terraform.tfstate`, ignorado por Git). Cuando el
`apply` se automatice desde GitHub Actions, se migrará a un backend remoto, por ejemplo Cloudflare R2
o HCP Terraform, con `terraform init -migrate-state`.

## CI

[`terraform.yml`](.github/workflows/terraform.yml) se ejecuta en cada pull request y en cada push a
`main`: `terraform fmt -check` en todo el repositorio, y `init` más `validate` en cada stack. No usa
credenciales ni aplica cambios.

## Próximos pasos

- Stack `domain`: DNSSEC, Email Routing y registros raíz y `www` del portafolio.
- Stack `portfolio`: el sitio de `vfernandezg.dev`.
- `healthy-bites`: registros `app.healthybites` y `api.healthybites`, proyectos de Vercel
  ([`vercel/vercel`](https://registry.terraform.io/providers/vercel/vercel)) y base de datos en Neon
  (provider comunitario [`kislerdm/neon`](https://registry.terraform.io/providers/kislerdm/neon)).
- Backend remoto para el _state_ y `plan`/`apply` desde GitHub Actions.
