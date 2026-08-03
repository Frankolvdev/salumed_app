import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Algunos plugins heredados no declaran compileSdk correctamente bajo AGP 9.
// Esto no cambia targetSdk ni comportamiento; solo permite compilar sus módulos Android.
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<LibraryExtension> {
            compileSdkVersion(37)
        }
    }
}

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
