# Stack `domain`

Configuración del dominio `vfernandezg.dev` en sí, no de un proyecto. Es la única stack que puede crear registros de
todo el dominio; las de proyecto (como `healthy-bites`) solo leen la zona.

| Pieza | Recurso |
| --- | --- |
| Verificación del dominio en GitHub Pages | TXT `_github-pages-challenge-vfernandezg-dev` ([`main.tf`](main.tf)). Impide que otra cuenta publique un sitio de Pages en el dominio o en sus subdominios directos. Debe quedarse. |

Pendiente de traer aquí: los registros de Email Routing (3 MX, DKIM y SPF), que hoy no gestiona ninguna stack.

## Uso

Desde la raíz del repo, con las credenciales cargadas (`. .\scripts\load-env.ps1` o `source scripts/load-env.sh`):

```powershell
cd stacks\domain
terraform init
terraform plan -out domain.tfplan
terraform apply domain.tfplan
```

El _state_ es local e ignorado por git, como en el resto de stacks.
