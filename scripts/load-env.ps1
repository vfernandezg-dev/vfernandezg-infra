# Carga las credenciales de .env (raíz del repo) en la sesión y las expone a Terraform como TF_VAR_*.
# Uso, desde la raíz del repo:  . .\scripts\load-env.ps1   (con el punto delante; no imprime ningún valor)
$envFile = Join-Path $PSScriptRoot '..\.env'
if (-not (Test-Path $envFile)) {
    throw 'No existe .env: copia .env.example y rellénalo.'
}
foreach ($line in Get-Content -Encoding UTF8 $envFile) {
    $trimmed = $line.Trim()
    if ($trimmed -eq '' -or $trimmed.StartsWith('#') -or -not $trimmed.Contains('=')) { continue }
    $key, $value = $trimmed.Split('=', 2)
    $value = $value.Trim().Trim('"').Trim("'")
    Set-Item -Path "Env:$($key.Trim())" -Value $value
}

# Variables de la stack healthy-bites (los providers leen sus tokens directamente del entorno).
$env:TF_VAR_cloudflare_account_id = $env:CLOUDFLARE_ACCOUNT_ID
$env:TF_VAR_vercel_team_id = $env:VERCEL_TEAM_ID
$env:TF_VAR_neon_org_id = $env:NEON_ORG_ID
$env:TF_VAR_r2_access_key_id = $env:R2_ACCESS_KEY_ID
$env:TF_VAR_r2_secret_access_key = $env:R2_SECRET_ACCESS_KEY
$env:TF_VAR_resend_smtp_key = $env:RESEND_SMTP_KEY
$env:TF_VAR_paypal_client_id = $env:PAYPAL_CLIENT_ID
$env:TF_VAR_paypal_client_secret = $env:PAYPAL_CLIENT_SECRET
$env:TF_VAR_primeng_license_key = $env:NG_APP_PRIMENG_LICENSE_KEY
