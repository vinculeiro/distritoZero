# Copia o build da app React (single-file) ao cartafol estático do Hugo.
# Executar dende a raíz de distritoZero, despois de: npm run build (en app_react).
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$src = Join-Path $repoRoot "..\02_administracion\actas_organos_colexiados\05_documentos\plenos_lalin_react.html"
$dstDir = Join-Path $repoRoot "static\apps\plenos-lalin"
$dst = Join-Path $dstDir "index.html"
if (-not (Test-Path $src)) {
  Write-Error "Non se atopou o build: $src`nExecuta antes: cd ...\app_react && npm run build"
}
New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
Copy-Item -Force $src $dst
Write-Host "Copiado a: $dst"
