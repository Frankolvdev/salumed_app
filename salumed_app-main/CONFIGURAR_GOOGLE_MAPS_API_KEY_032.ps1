$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$appGradlePath = Join-Path $projectRoot "android\app\build.gradle.kts"
$localPropertiesPath = Join-Path $projectRoot "android\local.properties"
$androidGitignorePath = Join-Path $projectRoot "android\.gitignore"

if (-not (Test-Path $appGradlePath)) {
    throw "No se encontró: $appGradlePath"
}

Write-Host "=== SaluMed: configuración segura de Google Maps API Key ===" -ForegroundColor Cyan

# 1. Asegurar que android/local.properties siga ignorado por Git.
if (-not (Test-Path $androidGitignorePath)) {
    New-Item -ItemType File -Path $androidGitignorePath -Force | Out-Null
}

$gitignore = Get-Content $androidGitignorePath -Raw -ErrorAction SilentlyContinue
if ($null -eq $gitignore) {
    $gitignore = ""
}

if ($gitignore -notmatch '(?m)^/local\.properties\s*$') {
    $gitignore = $gitignore.TrimEnd() + "`r`n/local.properties`r`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($androidGitignorePath, $gitignore, $utf8NoBom)
}

# 2. Crear o actualizar la línea GOOGLE_MAPS_API_KEY sin borrar sdk.dir.
if (-not (Test-Path $localPropertiesPath)) {
    New-Item -ItemType File -Path $localPropertiesPath -Force | Out-Null
}

$localProperties = Get-Content $localPropertiesPath -Raw -ErrorAction SilentlyContinue
if ($null -eq $localProperties) {
    $localProperties = ""
}

$keyLine = "GOOGLE_MAPS_API_KEY=PEGA_AQUI_TU_API_KEY"

if ($localProperties -match '(?m)^GOOGLE_MAPS_API_KEY=.*$') {
    $localProperties = [regex]::Replace(
        $localProperties,
        '(?m)^GOOGLE_MAPS_API_KEY=.*$',
        $keyLine,
        1
    )
} else {
    $localProperties = $localProperties.TrimEnd() + "`r`n$keyLine`r`n"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($localPropertiesPath, $localProperties, $utf8NoBom)

# 3. Conectar local.properties con el placeholder del AndroidManifest.
$gradle = Get-Content $appGradlePath -Raw -ErrorAction Stop
if ($null -eq $gradle -or $gradle.Length -eq 0) {
    throw "android\app\build.gradle.kts está vacío."
}

$begin = "// BEGIN SALUMED GOOGLE MAPS API KEY"
$end = "// END SALUMED GOOGLE MAPS API KEY"

$loaderBlock = @'
// BEGIN SALUMED GOOGLE MAPS API KEY
val salumedLocalProperties = java.util.Properties()
val salumedLocalPropertiesFile = rootProject.file("local.properties")

if (salumedLocalPropertiesFile.exists()) {
    salumedLocalPropertiesFile.inputStream().use {
        salumedLocalProperties.load(it)
    }
}

val salumedGoogleMapsApiKey =
    salumedLocalProperties.getProperty("GOOGLE_MAPS_API_KEY")?.trim().orEmpty()

if (
    salumedGoogleMapsApiKey.isBlank() ||
    salumedGoogleMapsApiKey == "PEGA_AQUI_TU_API_KEY"
) {
    throw GradleException(
        "Falta GOOGLE_MAPS_API_KEY. Abre android/local.properties y reemplaza " +
            "PEGA_AQUI_TU_API_KEY por tu clave real de Google Maps."
    )
}
// END SALUMED GOOGLE MAPS API KEY

'@

# Quitar una versión previa para que el script sea reutilizable.
$gradle = [regex]::Replace(
    $gradle,
    '(?s)// BEGIN SALUMED GOOGLE MAPS API KEY.*?// END SALUMED GOOGLE MAPS API KEY\s*',
    ''
)

$gradle = $loaderBlock + $gradle.TrimStart()

$placeholderLine = 'manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = salumedGoogleMapsApiKey'

if ($gradle -notmatch [regex]::Escape($placeholderLine)) {
    $defaultConfigPattern = '(?m)^(\s*)defaultConfig\s*\{\s*$'
    $match = [regex]::Match($gradle, $defaultConfigPattern)

    if (-not $match.Success) {
        throw "No se encontró el bloque defaultConfig en android\app\build.gradle.kts."
    }

    $indent = $match.Groups[1].Value + "    "
    $replacement = $match.Value + "`r`n" + $indent + $placeholderLine

    $gradle = $gradle.Substring(0, $match.Index) +
        $replacement +
        $gradle.Substring($match.Index + $match.Length)
}

[System.IO.File]::WriteAllText($appGradlePath, $gradle, $utf8NoBom)

# 4. Verificación.
$verifyGradle = Get-Content $appGradlePath -Raw
$verifyLocal = Get-Content $localPropertiesPath -Raw
$verifyIgnore = Get-Content $androidGitignorePath -Raw

if ($verifyGradle -notmatch 'getProperty\("GOOGLE_MAPS_API_KEY"\)') {
    throw "No se agregó la lectura de GOOGLE_MAPS_API_KEY."
}

if ($verifyGradle -notmatch 'manifestPlaceholders\["GOOGLE_MAPS_API_KEY"\]') {
    throw "No se configuró manifestPlaceholders."
}

if ($verifyLocal -notmatch '(?m)^GOOGLE_MAPS_API_KEY=PEGA_AQUI_TU_API_KEY$') {
    throw "No se creó la línea de configuración en android/local.properties."
}

if ($verifyIgnore -notmatch '(?m)^/local\.properties\s*$') {
    throw "android/local.properties no quedó protegido por .gitignore."
}

Write-Host ""
Write-Host "Configuración creada correctamente." -ForegroundColor Green
Write-Host ""
Write-Host "Ahora abre este archivo:" -ForegroundColor Yellow
Write-Host "android\local.properties"
Write-Host ""
Write-Host "Busca esta línea:" -ForegroundColor Yellow
Write-Host "GOOGLE_MAPS_API_KEY=PEGA_AQUI_TU_API_KEY"
Write-Host ""
Write-Host "Y reemplázala, por ejemplo:" -ForegroundColor Yellow
Write-Host "GOOGLE_MAPS_API_KEY=TU_CLAVE_REAL"
Write-Host ""
Write-Host "No agregues comillas y no subas local.properties a Git." -ForegroundColor Cyan
