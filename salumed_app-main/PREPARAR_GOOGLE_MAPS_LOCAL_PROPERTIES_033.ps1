$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$localPropertiesPath = Join-Path $projectRoot "android\local.properties"
$androidGitignorePath = Join-Path $projectRoot "android\.gitignore"

if (-not (Test-Path $localPropertiesPath)) {
    New-Item -ItemType File -Path $localPropertiesPath -Force | Out-Null
}

$lines = Get-Content $localPropertiesPath -ErrorAction SilentlyContinue
if ($null -eq $lines) {
    $lines = @()
}

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

if (-not (Test-Path $androidGitignorePath)) {
    New-Item -ItemType File -Path $androidGitignorePath -Force | Out-Null
}

$gitignore = Get-Content $androidGitignorePath -Raw -ErrorAction SilentlyContinue
if ($null -eq $gitignore) {
    $gitignore = ""
}

if ($gitignore -notmatch '(?m)^/local\.properties\s*$') {
    $gitignore = $gitignore.TrimEnd() + "`r`n/local.properties`r`n"
    [System.IO.File]::WriteAllText($androidGitignorePath, $gitignore, $utf8NoBom)
}

Write-Host ""
Write-Host "Listo. Abre android\local.properties y reemplaza:" -ForegroundColor Green
Write-Host "GOOGLE_MAPS_API_KEY=PEGA_AQUI_TU_API_KEY"
Write-Host "por tu clave real, sin comillas."
