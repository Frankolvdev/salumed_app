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
                    project.name == "audio_session" ||
                    project.name == "audioplayers_android"
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
