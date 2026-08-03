$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pubspecPath = Join-Path $projectRoot "pubspec.yaml"
$rootGradle = Join-Path $projectRoot "android\build.gradle.kts"
$cachePlugin = Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev\assets_audio_player-3.1.1"
$localPlugin = Join-Path $projectRoot "plugins\assets_audio_player"
$pluginGradle = Join-Path $localPlugin "android\build.gradle"

if (-not (Test-Path $pubspecPath)) {
    throw "No se encontró pubspec.yaml"
}

if (-not (Test-Path $rootGradle)) {
    throw "No se encontró android\build.gradle.kts"
}

if (-not (Test-Path $cachePlugin)) {
    throw @"
No se encontró assets_audio_player-3.1.1 en Pub Cache:
$cachePlugin

Ejecuta primero:
flutter pub get
"@
}

Write-Host "=== SaluMed: preparando assets_audio_player local ===" -ForegroundColor Cyan

# 1. Elimina únicamente el bloque problemático del parche 01X.
$gradleContent = Get-Content $rootGradle -Raw -ErrorAction Stop

$gradleContent = [regex]::Replace(
    $gradleContent,
    '(?s)\s*// BEGIN SALUMED ANDROID COMPILE OPTIONS 17.*?// END SALUMED ANDROID COMPILE OPTIONS 17\s*',
    "`r`n"
)

Set-Content -Path $rootGradle -Value $gradleContent.TrimEnd() -Encoding UTF8

# 2. Copia exacta del plugin 3.1.1 al proyecto.
if (Test-Path $localPlugin) {
    Remove-Item -Recurse -Force $localPlugin
}

New-Item -ItemType Directory -Force (Split-Path $localPlugin -Parent) | Out-Null
Copy-Item -Recurse -Force $cachePlugin $localPlugin

if (-not (Test-Path $pluginGradle)) {
    throw "La copia local no contiene android\build.gradle"
}

# 3. Corrige directamente el Gradle del plugin local.
$content = Get-Content $pluginGradle -Raw -ErrorAction Stop

$content = $content -replace 'jcenter\(\)', 'mavenCentral()'

$content = [regex]::Replace(
    $content,
    '(?m)^\s*sourceCompatibility\s+JavaVersion\.VERSION_1_8\s*$',
    '        sourceCompatibility JavaVersion.VERSION_17'
)

$content = [regex]::Replace(
    $content,
    '(?m)^\s*targetCompatibility\s+JavaVersion\.VERSION_1_8\s*$',
    '        targetCompatibility JavaVersion.VERSION_17'
)

if ($content -notmatch 'sourceCompatibility\s+JavaVersion\.VERSION_17') {
    $content = [regex]::Replace(
        $content,
        'compileOptions\s*\{',
        "compileOptions {`r`n        sourceCompatibility JavaVersion.VERSION_17",
        1
    )
}

if ($content -notmatch 'targetCompatibility\s+JavaVersion\.VERSION_17') {
    $content = [regex]::Replace(
        $content,
        'compileOptions\s*\{',
        "compileOptions {`r`n        targetCompatibility JavaVersion.VERSION_17",
        1
    )
}

# Ajusta Kotlin si el plugin conserva jvmTarget antiguo.
$content = [regex]::Replace(
    $content,
    '(?m)^\s*jvmTarget\s*=\s*["'']1\.8["'']\s*$',
    "        jvmTarget = '17'"
)

Set-Content -Path $pluginGradle -Value $content -Encoding UTF8

# 4. Agrega/actualiza dependency_override local.
$pubspec = Get-Content $pubspecPath -Raw -ErrorAction Stop

if ($pubspec -notmatch '(?m)^dependency_overrides:\s*$') {
    $pubspec = $pubspec.TrimEnd() + "`r`n`r`ndependency_overrides:`r`n"
}

if ($pubspec -match '(?ms)^\s{2}assets_audio_player:\s*\r?\n\s{4}path:\s*.*$') {
    $pubspec = [regex]::Replace(
        $pubspec,
        '(?ms)^\s{2}assets_audio_player:\s*\r?\n\s{4}path:\s*.*$',
        "  assets_audio_player:`r`n    path: plugins/assets_audio_player"
    )
} else {
    $pubspec = [regex]::Replace(
        $pubspec,
        '(?m)^dependency_overrides:\s*$',
        "dependency_overrides:`r`n  assets_audio_player:`r`n    path: plugins/assets_audio_player",
        1
    )
}

Set-Content -Path $pubspecPath -Value $pubspec -Encoding UTF8

# 5. Verificación.
$verifyGradle = Get-Content $pluginGradle -Raw
$verifyPubspec = Get-Content $pubspecPath -Raw
$verifyRoot = Get-Content $rootGradle -Raw

if ($verifyRoot -match 'BEGIN SALUMED ANDROID COMPILE OPTIONS 17') {
    throw "No se eliminó el bloque problemático 01X."
}

if ($verifyGradle -notmatch 'sourceCompatibility\s+JavaVersion\.VERSION_17') {
    throw "No se aplicó sourceCompatibility Java 17 al plugin local."
}

if ($verifyGradle -notmatch 'targetCompatibility\s+JavaVersion\.VERSION_17') {
    throw "No se aplicó targetCompatibility Java 17 al plugin local."
}

if ($verifyPubspec -notmatch 'path:\s*plugins/assets_audio_player') {
    throw "No se agregó el override local de assets_audio_player."
}

Write-Host ""
Write-Host "assets_audio_player local preparado correctamente." -ForegroundColor Green
Write-Host "Java del plugin: 17"
Write-Host "Override local activo: plugins/assets_audio_player"
Write-Host "Bloque 01X problemático eliminado."
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "cd .\android"
Write-Host ".\gradlew.bat --stop"
Write-Host "cd .."
Write-Host "flutter clean"
Write-Host "Remove-Item -Recurse -Force .\android\.gradle -ErrorAction SilentlyContinue"
Write-Host "Remove-Item -Recurse -Force .\.dart_tool -ErrorAction SilentlyContinue"
Write-Host "Remove-Item -Force .\pubspec.lock -ErrorAction SilentlyContinue"
Write-Host "flutter pub get"
Write-Host "flutter run"
