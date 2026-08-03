$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev\assets_audio_player_web-3.1.1"
$pluginsRoot = Join-Path $projectRoot "plugins"
$destination = Join-Path $pluginsRoot "assets_audio_player_web"
$androidGradle = Join-Path $destination "android\build.gradle"

Write-Host "=== SaluMed: preparando assets_audio_player_web local ===" -ForegroundColor Cyan

if (-not (Test-Path $source)) {
    throw @"
No se encontró:
$source

Ejecuta primero:
flutter pub get

Después vuelve a ejecutar:
.\INSTALAR_PLUGIN_AUDIO_WEB_LOCAL.ps1
"@
}

if (Test-Path $destination) {
    Remove-Item -Recurse -Force $destination
}

New-Item -ItemType Directory -Force $pluginsRoot | Out-Null
Copy-Item -Recurse -Force $source $destination

if (-not (Test-Path $androidGradle)) {
    throw "La copia local no contiene android\build.gradle: $androidGradle"
}

$content = Get-Content $androidGradle -Raw

# Reemplaza cualquiera de las sintaxis antiguas de compileSdk.
$content = [regex]::Replace(
    $content,
    '(?m)^\s*compileSdkVersion\s+\d+\s*$',
    '    compileSdkVersion 37'
)
$content = [regex]::Replace(
    $content,
    '(?m)^\s*compileSdk\s+\d+\s*$',
    '    compileSdk 37'
)

# Si el plugin no declaraba compileSdk, lo agrega al bloque android.
if ($content -notmatch '(?m)^\s*compileSdk(?:Version)?\s+37\s*$') {
    $content = [regex]::Replace(
        $content,
        'android\s*\{',
        "android {`r`n    compileSdkVersion 37",
        1
    )
}

# AGP moderno necesita namespace. Solo se agrega si no existe.
if ($content -notmatch '(?m)^\s*namespace\s+') {
    $content = [regex]::Replace(
        $content,
        'android\s*\{',
        "android {`r`n    namespace 'com.github.florent37.assets_audio_player_web'",
        1
    )
}

# Elimina jcenter si apareciera en la copia publicada.
$content = $content -replace 'jcenter\(\)', 'mavenCentral()'

Set-Content -Path $androidGradle -Value $content -Encoding UTF8

$pubspecLocal = Join-Path $destination "pubspec.yaml"
if (-not (Test-Path $pubspecLocal)) {
    throw "La copia local no contiene pubspec.yaml"
}

Write-Host ""
Write-Host "Plugin copiado y corregido correctamente:" -ForegroundColor Green
Write-Host $destination
Write-Host ""
Write-Host "Verificaciones:" -ForegroundColor Cyan
Select-String -Path $androidGradle -Pattern "compileSdk|namespace|mavenCentral" |
    ForEach-Object { Write-Host $_.Line }
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "flutter clean"
Write-Host "Remove-Item -Recurse -Force .\.dart_tool -ErrorAction SilentlyContinue"
Write-Host "Remove-Item -Force .\pubspec.lock -ErrorAction SilentlyContinue"
Write-Host "flutter pub get"
Write-Host "flutter run"
