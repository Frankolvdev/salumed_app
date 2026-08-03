$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$cacheRoot = Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev"
$pluginsRoot = Join-Path $projectRoot "plugins"

function Copy-And-Patch-DatePicker {
    $source = Join-Path $cacheRoot "flutter_datetime_picker-1.5.1"
    $destination = Join-Path $pluginsRoot "flutter_datetime_picker"

    if (-not (Test-Path $source)) {
        throw "No se encontró flutter_datetime_picker-1.5.1. Ejecuta flutter pub get primero."
    }

    if (Test-Path $destination) {
        Remove-Item -Recurse -Force $destination
    }

    Copy-Item -Recurse -Force $source $destination

    $mainFile = Join-Path $destination "lib\flutter_datetime_picker.dart"
    $content = Get-Content $mainFile -Raw
    $content = $content.Replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart' hide DatePickerTheme;"
    )
    Set-Content -Path $mainFile -Value $content -Encoding UTF8

    if ((Get-Content $mainFile -Raw) -notmatch "hide DatePickerTheme") {
        throw "No se pudo corregir DatePickerTheme."
    }

    Write-Host "flutter_datetime_picker local corregido." -ForegroundColor Green
}

function Copy-And-Patch-Timelines {
    $source = Join-Path $cacheRoot "timelines-0.1.0"
    $destination = Join-Path $pluginsRoot "timelines"

    if (-not (Test-Path $source)) {
        throw "No se encontró timelines-0.1.0. Ejecuta flutter pub get primero."
    }

    if (Test-Path $destination) {
        Remove-Item -Recurse -Force $destination
    }

    Copy-Item -Recurse -Force $source $destination

    $connector = Join-Path $destination "lib\src\connector_theme.dart"
    $indicator = Join-Path $destination "lib\src\indicator_theme.dart"
    $timeline = Join-Path $destination "lib\src\timeline_theme.dart"

    foreach ($file in @($connector, $indicator)) {
        $content = Get-Content $file -Raw
        $content = $content.Replace("hashValues(", "Object.hash(")
        Set-Content -Path $file -Value $content -Encoding UTF8
    }

    $content = Get-Content $timeline -Raw
    $content = $content.Replace("hashList(values)", "Object.hashAll(values)")
    Set-Content -Path $timeline -Value $content -Encoding UTF8

    Write-Host "timelines local corregido." -ForegroundColor Green
}

Write-Host "=== SaluMed: corrigiendo paquetes heredados ===" -ForegroundColor Cyan
New-Item -ItemType Directory -Force $pluginsRoot | Out-Null

Copy-And-Patch-DatePicker
Copy-And-Patch-Timelines

Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "flutter clean"
Write-Host "Remove-Item -Recurse -Force .\.dart_tool -ErrorAction SilentlyContinue"
Write-Host "Remove-Item -Force .\pubspec.lock -ErrorAction SilentlyContinue"
Write-Host "flutter pub get"
Write-Host "flutter run"
