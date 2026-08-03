$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$gradlePath = Join-Path $projectRoot "android\build.gradle.kts"

if (-not (Test-Path $gradlePath)) {
    throw "No se encontró: $gradlePath"
}

$content = Get-Content $gradlePath -Raw -ErrorAction Stop
if ($null -eq $content) {
    throw "android\build.gradle.kts está vacío."
}

# Elimina el bloque global creado por MegaZIP 022, que forzaba JVM 17
# también en plugins cuyo Java target es 11.
$pattern = '(?s)// AGP 9 compila los módulos Android con Java 17\..*?subprojects\s*\{\s*plugins\.withId\("org\.jetbrains\.kotlin\.android"\)\s*\{.*?\n\}\s*$'
$content = [regex]::Replace($content, $pattern, '')

# También elimina cualquier bloque previo de esta corrección para hacer
# el script idempotente.
$content = [regex]::Replace(
    $content,
    '(?s)\s*// BEGIN SALUMED JVM POR MODULO.*?// END SALUMED JVM POR MODULO\s*',
    "`r`n"
)

$block = @'

// BEGIN SALUMED JVM POR MODULO
subprojects {
    plugins.withId("org.jetbrains.kotlin.android") {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                // La app, assets_audio_player y audio_session compilan Java 17.
                // Los demás plugins heredados, incluido file_picker, compilan Java 11.
                val target = if (
                    project.name == "app" ||
                    project.name == "assets_audio_player" ||
                    project.name == "audio_session"
                ) {
                    org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
                } else {
                    org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
                }

                jvmTarget.set(target)
            }
        }
    }
}
// END SALUMED JVM POR MODULO
'@

$content = $content.TrimEnd() + "`r`n`r`n" + $block.Trim() + "`r`n"

# Guardar UTF-8 sin BOM.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($gradlePath, $content, $utf8NoBom)

$verify = Get-Content $gradlePath -Raw
if ($verify -notmatch 'BEGIN SALUMED JVM POR MODULO') {
    throw "No se agregó el bloque JVM por módulo."
}
if ($verify -notmatch 'project\.name == "file_picker"' -and
    $verify -notmatch 'JvmTarget\.JVM_11') {
    throw "No se pudo verificar JVM 11 para plugins heredados."
}
if ($verify -notmatch 'project\.name == "audio_session"') {
    throw "No se pudo verificar JVM 17 para audio_session."
}

Write-Host "Configuración JVM por módulo aplicada correctamente." -ForegroundColor Green
Write-Host ""
Write-Host "JVM 17: app, assets_audio_player, audio_session"
Write-Host "JVM 11: file_picker y demás plugins Android heredados"
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "cd .\android"
Write-Host ".\gradlew.bat --stop"
Write-Host "cd .."
Write-Host "flutter clean"
Write-Host "Remove-Item -Recurse -Force .\build -ErrorAction SilentlyContinue"
Write-Host "Remove-Item -Recurse -Force .\.dart_tool -ErrorAction SilentlyContinue"
Write-Host "Remove-Item -Recurse -Force .\android\.gradle -ErrorAction SilentlyContinue"
Write-Host "flutter pub get"
Write-Host "flutter build apk --debug -v *> build_023.log"
