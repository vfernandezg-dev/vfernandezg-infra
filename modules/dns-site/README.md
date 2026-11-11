# Módulo `dns-site`

Publica un sitio en un subdominio: crea un `CNAME` desde `<subdomain>.<zone_name>` hacia su hosting.

```hcl
module "landing" {
  source = "../../modules/dns-site"

  zone_id   = data.cloudflare_zone.main.id
  zone_name = "vfernandezg.dev"
  subdomain = "healthybites"
  target    = "vfernandezg-dev.github.io"
}
```

| Variable    | Tipo     | Por defecto                                   | Descripción                                                    |
| ----------- | -------- | --------------------------------------------- | -------------------------------------------------------------- |
| `zone_id`   | `string` | —                                             | ID de la zona en Cloudflare                                    |
| `zone_name` | `string` | —                                             | Nombre de la zona                                              |
| `subdomain` | `string` | —                                             | Subdominio sin la zona (`healthybites`, `app.healthybites`)    |
| `target`    | `string` | —                                             | Host de destino del CNAME                                      |
| `proxied`   | `bool`   | `false`                                       | Proxy de Cloudflare; `false` si el hosting emite su certificado |
| `comment`   | `string` | `"Gestionado con Terraform (vfernandezg-infra)"` | Nota visible en el panel de Cloudflare                       |

Salidas: `fqdn`, `url` y `record_id`.
