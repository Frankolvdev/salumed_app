$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$libRoot = Join-Path $projectRoot "lib"

if (-not (Test-Path $libRoot)) {
    throw "No se encontró la carpeta lib en $projectRoot"
}

Write-Host "=== SaluMed: migración final Font Awesome 11 ===" -ForegroundColor Cyan

$changedFiles = 0
$iconToFaIcon = 0
$iconDataAdded = 0
$emptyFilesSkipped = 0

$dartFiles = Get-ChildItem $libRoot -Recurse -Filter *.dart -File

foreach ($file in $dartFiles) {
    $original = Get-Content $file.FullName -Raw -ErrorAction Stop

    if ($null -eq $original -or $original.Length -eq 0) {
        $emptyFilesSkipped++
        continue
    }

    $content = [string]$original

    $patternIcon = '\bIcon\(\s*FontAwesomeIcons\s*\.\s*([A-Za-z0-9_]+)'
    $matchesIcon = [regex]::Matches(
        $content,
        $patternIcon,
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    $iconToFaIcon += $matchesIcon.Count

    $content = [regex]::Replace(
        $content,
        $patternIcon,
        'FaIcon(FontAwesomeIcons.$1',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $protected = @{}
    $script:faCounter = 0

    $content = [regex]::Replace(
        $content,
        '\bFaIcon\(\s*FontAwesomeIcons\s*\.\s*([A-Za-z0-9_]+)',
        {
            param($match)
            $key = "__SALUMED_FAICON_$($script:faCounter)__"
            $protected[$key] = $match.Value
            $script:faCounter++
            return $key
        },
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $patternData = 'FontAwesomeIcons\s*\.\s*([A-Za-z0-9_]+)(?![A-Za-z0-9_])'
    $matchesData = [regex]::Matches(
        $content,
        $patternData,
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    $iconDataAdded += $matchesData.Count

    $content = [regex]::Replace(
        $content,
        $patternData,
        'FontAwesomeIcons.$1.data',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $content = $content.Replace('.data.data', '.data')

    foreach ($entry in $protected.GetEnumerator()) {
        $content = $content.Replace($entry.Key, $entry.Value)
    }

    if ($content -ne $original) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $changedFiles++
    }
}

Write-Host ""
Write-Host "Verificando el repositorio completo..." -ForegroundColor Cyan

$errors = New-Object System.Collections.Generic.List[string]

foreach ($file in (Get-ChildItem $libRoot -Recurse -Filter *.dart -File)) {
    $raw = Get-Content $file.FullName -Raw -ErrorAction Stop

    if ($null -eq $raw -or $raw.Length -eq 0) {
        continue
    }

    $content = [string]$raw

    if ([regex]::IsMatch(
        $content,
        '\bIcon\(\s*FontAwesomeIcons\s*\.',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )) {
        $errors.Add("Icon(FontAwesomeIcons...) restante: $($file.FullName)")
    }

    $check = [regex]::Replace(
        $content,
        '\bFaIcon\(\s*FontAwesomeIcons\s*\.\s*[A-Za-z0-9_]+',
        '',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $rawMatches = [regex]::Matches(
        $check,
        'FontAwesomeIcons\s*\.\s*([A-Za-z0-9_]+)',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    foreach ($match in $rawMatches) {
        $suffixStart = $match.Index + $match.Length
        $suffixLength = [Math]::Min(12, $check.Length - $suffixStart)
        $suffix = $check.Substring($suffixStart, $suffixLength)

        if ($suffix -notmatch '^\s*\.data\b') {
            $errors.Add(
                "FontAwesomeIcons sin FaIcon ni .data: $($file.FullName) -> $($match.Value)"
            )
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "La verificación encontró problemas:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    throw "La migración no quedó completa. Revisa los mensajes anteriores."
}

Write-Host ""
Write-Host "Migración terminada y verificada." -ForegroundColor Green
Write-Host "Archivos modificados: $changedFiles"
Write-Host "Icon(...) convertidos a FaIcon(...): $iconToFaIcon"
Write-Host "Referencias IconData con .data: $iconDataAdded"
Write-Host "Archivos Dart vacíos ignorados: $emptyFilesSkipped"
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "flutter clean"
Write-Host "Remove-Item -Recurse -Force .\.dart_tool -ErrorAction SilentlyContinue"
Write-Host "flutter pub get"
Write-Host "flutter run"
