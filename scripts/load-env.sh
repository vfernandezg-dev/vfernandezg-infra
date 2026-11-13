# Carga las credenciales de .env (raíz del repo) en la sesión y las expone a Terraform como TF_VAR_*.
# Uso, desde la raíz del repo:  source scripts/load-env.sh   (no imprime ningún valor)
_env_file="$(dirname "${BASH_SOURCE[0]}")/../.env"
if [ ! -f "$_env_file" ]; then
  echo "No existe .env: copia .env.example y rellénalo." >&2
  return 1 2>/dev/null || exit 1
fi
while IFS= read -r _line || [ -n "$_line" ]; do
  _line="${_line%$'\r'}"
  case "$_line" in '' | \#*) continue ;; esac
  _key="$(printf '%s' "${_line%%=*}" | tr -d ' ')"
  _val="${_line#*=}"
  _val="${_val%\"}"; _val="${_val#\"}"; _val="${_val%\'}"; _val="${_val#\'}"
  export "$_key=$_val"
done < "$_env_file"

# Variables de la stack healthy-bites (los providers leen sus tokens directamente del entorno).
export TF_VAR_cloudflare_account_id="$CLOUDFLARE_ACCOUNT_ID"
export TF_VAR_vercel_team_id="$VERCEL_TEAM_ID"
export TF_VAR_neon_org_id="$NEON_ORG_ID"
export TF_VAR_r2_access_key_id="$R2_ACCESS_KEY_ID"
export TF_VAR_r2_secret_access_key="$R2_SECRET_ACCESS_KEY"
export TF_VAR_resend_smtp_key="$RESEND_SMTP_KEY"
export TF_VAR_paypal_client_id="$PAYPAL_CLIENT_ID"
export TF_VAR_paypal_client_secret="$PAYPAL_CLIENT_SECRET"
export TF_VAR_primeng_license_key="$NG_APP_PRIMENG_LICENSE_KEY"
unset _env_file _line _key _val
