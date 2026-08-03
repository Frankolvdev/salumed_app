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

$begin = "// BEGIN SALUMED JVM TARGET 17"
$end = "// END SALUMED JVM TARGET 17"

$block = @'

// BEGIN SALUMED JVM TARGET 17
subprojects {
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}
// END SALUMED JVM TARGET 17
'@

if ($content.Contains($begin)) {
    $pattern = '(?s)// BEGIN SALUMED JVM TARGET 17.*?// END SALUMED JVM TARGET 17'
    $content = [regex]::Replace($content, $pattern, $block.Trim())
} else {
    $content = $content.TrimEnd() + "`r`n" + $block + "`r`n"
}

Set-Content -Path $gradlePath -Value $content -Encoding UTF8

$verify = Get-Content $gradlePath -Raw
if (
    $verify -notmatch 'sourceCompatibility = "17"' -or
    $verify -notmatch 'targetCompatibility = "17"' -or
    $verify -notmatch 'JvmTarget\.JVM_17'
) {
    throw "No se pudo verificar la configuración JVM 17."
}

Write-Host "Configuración JVM 17 aplicada correctamente." -ForegroundColor Green
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
