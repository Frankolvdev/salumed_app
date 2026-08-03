$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$localPropertiesPath = Join-Path $projectRoot "android\local.properties"

if (-not (Test-Path $localPropertiesPath)) {
    throw "No se encontró: $localPropertiesPath"
}

Write-Host "=== SaluMed: corrección de GOOGLE_MAPS_API_KEY ===" -ForegroundColor Cyan

$lines = Get-Content $localPropertiesPath -ErrorAction Stop
$newLines = New-Object System.Collections.Generic.List[string]
$found = $false

foreach ($line in $lines) {
    if ($line -match '^\s*GOOGLE_MAPS_API_KEY\s*=') {
        $newLines.Add("GOOGLE_MAPS_API_KEY=PEGA_AQUI_TU_API_KEY")
        $found = $true
    } else {
        $newLines.Add($line)
    }
}

if (-not $found) {
    $newLines.Add("GOOGLE_MAPS_API_KEY=PEGA_AQUI_TU_API_KEY")
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($localPropertiesPath, $newLines, $utf8NoBom)

# Verificación robusta: acepta CRLF, espacios y archivo sin salto final.
$verifyLines = Get-Content $localPropertiesPath -ErrorAction Stop
$keyLine = $verifyLines | Where-Object {
    $_ -match '^\s*GOOGLE_MAPS_API_KEY\s*=\s*PEGA_AQUI_TU_API_KEY\s*$'
} | Select-Object -First 1

if ($null -eq $keyLine) {
    throw "No se pudo verificar GOOGLE_MAPS_API_KEY en android/local.properties."
}

Write-Host ""
Write-Host "La línea fue creada correctamente." -ForegroundColor Green
Write-Host ""
Write-Host "Abre:" -ForegroundColor Yellow
Write-Host "android\local.properties"
Write-Host ""
Write-Host "Reemplaza:" -ForegroundColor Yellow
Write-Host "GOOGLE_MAPS_API_KEY=PEGA_AQUI_TU_API_KEY"
Write-Host ""
Write-Host "Por tu clave real, sin comillas:" -ForegroundColor Yellow
Write-Host "GOOGLE_MAPS_API_KEY=AIza..."
