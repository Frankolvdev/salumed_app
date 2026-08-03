$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$gradlePath = Join-Path $projectRoot "plugins\assets_audio_player\android\build.gradle"

if (-not (Test-Path $gradlePath)) {
    throw "No se encontró: $gradlePath"
}

# Lee bytes y elimina BOM UTF-8 EF BB BF si existe.
$bytes = [System.IO.File]::ReadAllBytes($gradlePath)

if ($bytes.Length -ge 3 -and
    $bytes[0] -eq 0xEF -and
    $bytes[1] -eq 0xBB -and
    $bytes[2] -eq 0xBF) {

    $clean = New-Object byte[] ($bytes.Length - 3)
    [Array]::Copy($bytes, 3, $clean, 0, $clean.Length)
    [System.IO.File]::WriteAllBytes($gradlePath, $clean)

    Write-Host "BOM UTF-8 eliminado correctamente." -ForegroundColor Green
} else {
    Write-Host "El archivo no tenía BOM UTF-8. No se modificó." -ForegroundColor Yellow
}

# Verificación.
$verify = [System.IO.File]::ReadAllBytes($gradlePath)
if ($verify.Length -ge 3 -and
    $verify[0] -eq 0xEF -and
    $verify[1] -eq 0xBB -and
    $verify[2] -eq 0xBF) {
    throw "El BOM sigue presente."
}

Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "cd .\android"
Write-Host ".\gradlew.bat --stop"
Write-Host "cd .."
Write-Host "flutter clean"
Write-Host "Remove-Item -Recurse -Force .\android\.gradle -ErrorAction SilentlyContinue"
Write-Host "flutter pub get"
Write-Host "flutter run"
