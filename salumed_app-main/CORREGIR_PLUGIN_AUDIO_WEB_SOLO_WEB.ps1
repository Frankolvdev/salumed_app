$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginRoot = Join-Path $projectRoot "plugins\assets_audio_player_web"
$pubspecPath = Join-Path $pluginRoot "pubspec.yaml"
$androidPath = Join-Path $pluginRoot "android"

Write-Host "=== SaluMed: dejando assets_audio_player_web solo para Web ===" -ForegroundColor Cyan

if (-not (Test-Path $pubspecPath)) {
    throw "No se encontró el pubspec local del plugin: $pubspecPath"
}

$content = Get-Content $pubspecPath -Raw

# Elimina únicamente la plataforma Android declarada dentro de:
# flutter:
#   plugin:
#     platforms:
#       android:
#         package: ...
#         pluginClass: ...
#
# Se detiene al encontrar la siguiente plataforma con la misma indentación.
$pattern = '(?ms)^(\s{6}android:\s*\r?\n)(?:\s{8,}.*\r?\n)+(?=\s{6}[a-zA-Z_]+:\s*$)'

$updated = [regex]::Replace($content, $pattern, '', 1)

if ($updated -eq $content) {
    # Variante con cuatro espacios de indentación.
    $patternAlt = '(?ms)^(\s{4}android:\s*\r?\n)(?:\s{6,}.*\r?\n)+(?=\s{4}[a-zA-Z_]+:\s*$)'
    $updated = [regex]::Replace($content, $patternAlt, '', 1)
}

if ($updated -eq $content) {
    throw @"
No se pudo localizar automáticamente el bloque Android dentro de:
$pubspecPath

No se modificó ningún archivo.
"@
}

Set-Content -Path $pubspecPath -Value $updated -Encoding UTF8

# El código Android de este paquete web ya no debe formar parte de la compilación.
if (Test-Path $androidPath) {
    Remove-Item -Recurse -Force $androidPath
}

Write-Host ""
Write-Host "Plugin corregido correctamente." -ForegroundColor Green
Write-Host "Se eliminó únicamente el registro/plataforma Android."
Write-Host "La implementación Web permanece intacta."
Write-Host ""
Write-Host "Comprobación de plataformas restantes:" -ForegroundColor Cyan

$show = $false
Get-Content $pubspecPath | ForEach-Object {
    if ($_ -match '^\s*platforms:\s*$') {
        $show = $true
    }
    if ($show) {
        Write-Host $_
    }
}

Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "cd .\android"
Write-Host ".\gradlew.bat --stop"
Write-Host "cd .."
Write-Host "flutter clean"
Write-Host "Remove-Item -Recurse -Force .\.dart_tool -ErrorAction SilentlyContinue"
Write-Host "Remove-Item -Recurse -Force .\android\.gradle -ErrorAction SilentlyContinue"
Write-Host "Remove-Item -Force .\pubspec.lock -ErrorAction SilentlyContinue"
Write-Host "flutter pub get"
Write-Host "flutter run"
