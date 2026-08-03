import java.util.Properties

// BEGIN SALUMED GOOGLE MAPS API KEY
val salumedLocalProperties = Properties()
val salumedLocalPropertiesFile = rootProject.file("local.properties")

if (salumedLocalPropertiesFile.exists()) {
    salumedLocalPropertiesFile.inputStream().use { input ->
        salumedLocalProperties.load(input)
    }
}

val salumedGoogleMapsApiKey =
    salumedLocalProperties.getProperty("GOOGLE_MAPS_API_KEY")?.trim().orEmpty()

if (
    salumedGoogleMapsApiKey.isBlank() ||
    salumedGoogleMapsApiKey == "PEGA_AQUI_TU_API_KEY"
) {
    throw GradleException(
        "Falta GOOGLE_MAPS_API_KEY. Abre android/local.properties y reemplaza " +
            "PEGA_AQUI_TU_API_KEY por tu clave real de Google Maps."
    )
}
// END SALUMED GOOGLE MAPS API KEY

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.salumed.app"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {

        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = salumedGoogleMapsApiKey
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.salumed.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
