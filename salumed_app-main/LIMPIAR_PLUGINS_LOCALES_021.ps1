$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$targets = @(
  "plugins\assets_audio_player\example",
  "plugins\assets_audio_player\test",
  "plugins\assets_audio_player\assets_audio_player_web",
  "plugins\assets_audio_player_web\example",
  "plugins\assets_audio_player_web\test",
  "plugins\flutter_datetime_picker\example",
  "plugins\flutter_datetime_picker\test",
  "plugins\timelines\example",
  "plugins\timelines\test"
)

foreach ($relative in $targets) {
    $path = Join-Path $root $relative
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path
        Write-Host "Eliminado: $relative" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Limpieza de plugins locales completada." -ForegroundColor Cyan
