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

$pattern = '(?s)// BEGIN SALUMED JVM AUTOMATICA.*?// END SALUMED JVM AUTOMATICA'

$replacement = @'
// BEGIN SALUMED JVM AUTOMATICA
// Alinea cada tarea Kotlin con la tarea Java equivalente del mismo módulo.
// Guarda explícitamente la tarea Kotlin antes de configurar JavaCompile.
subprojects {
    plugins.withId("org.jetbrains.kotlin.android") {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            val kotlinTask = this
            val javaTaskName = name.replace("Kotlin", "JavaWithJavac")

            project.tasks.withType<org.gradle.api.tasks.compile.JavaCompile>()
                .matching { it.name == javaTaskName }
                .configureEach {
                    val javaTarget = targetCompatibility

                    val kotlinTarget =
                        when (javaTarget) {
                            "1.8", "8" ->
                                org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8
                            "11" ->
                                org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
                            "17" ->
                                org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
                            "21" ->
                                org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21
                            else ->
                                org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(javaTarget)
                        }

                    kotlinTask.compilerOptions {
                        jvmTarget.set(kotlinTarget)
                    }
                }
        }
    }
}
// END SALUMED JVM AUTOMATICA
'@

if (-not [regex]::IsMatch($content, $pattern)) {
    throw "No se encontró el bloque SALUMED JVM AUTOMATICA en android\build.gradle.kts."
}

$content = [regex]::Replace($content, $pattern, $replacement, 1)

# Guardar UTF-8 sin BOM.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($gradlePath, $content, $utf8NoBom)

$verify = Get-Content $gradlePath -Raw

if ($verify -notmatch 'val kotlinTask = this') {
    throw "No se agregó la referencia explícita kotlinTask."
}

if ($verify -notmatch 'kotlinTask\.compilerOptions') {
    throw "No se aplicó compilerOptions sobre kotlinTask."
}

if ($verify -match 'this@configureEach\.compilerOptions') {
    throw "Todavía quedó la referencia incorrecta this@configureEach.compilerOptions."
}

Write-Host "Bloque JVM automático corregido correctamente." -ForegroundColor Green
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
Write-Host "flutter build apk --debug -v *> build_030.log"
