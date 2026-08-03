$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$gradlePath = Join-Path $projectRoot "android\build.gradle.kts"

if (-not (Test-Path $gradlePath)) {
    throw "No se encontró: $gradlePath"
}

$content = Get-Content $gradlePath -Raw -ErrorAction Stop
if ($null -eq $content) {
    throw "El archivo android\build.gradle.kts está vacío."
}

$begin = "// BEGIN SALUMED ANDROID COMPILE OPTIONS 17"
$end = "// END SALUMED ANDROID COMPILE OPTIONS 17"

$block = @'

// BEGIN SALUMED ANDROID COMPILE OPTIONS 17
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }

    plugins.withId("com.android.application") {
        extensions.configure<com.android.build.gradle.AppExtension> {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
}
// END SALUMED ANDROID COMPILE OPTIONS 17
'@

if ($content.Contains($begin)) {
    $pattern = '(?s)// BEGIN SALUMED ANDROID COMPILE OPTIONS 17.*?// END SALUMED ANDROID COMPILE OPTIONS 17'
    $content = [regex]::Replace($content, $pattern, $block.Trim())
} else {
    $content = $content.TrimEnd() + "`r`n" + $block + "`r`n"
}

Set-Content -Path $gradlePath -Value $content -Encoding UTF8

$verify = Get-Content $gradlePath -Raw
if (
    $verify -notmatch 'sourceCompatibility = JavaVersion\.VERSION_17' -or
    $verify -notmatch 'targetCompatibility = JavaVersion\.VERSION_17'
) {
    throw "No se pudo verificar compileOptions Java 17."
}

Write-Host "compileOptions Java 17 aplicado a app y plugins Android." -ForegroundColor Green
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "cd .\android"
Write-Host ".\gradlew.bat --stop"
Write-Host "cd .."
Write-Host "flutter clean"
Write-Host "Remove-Item -Recurse -Force .\android\.gradle -ErrorAction SilentlyContinue"
Write-Host "Remove-Item -Recurse -Force .\.dart_tool -ErrorAction SilentlyContinue"
Write-Host "flutter pub get"
Write-Host "flutter run"
