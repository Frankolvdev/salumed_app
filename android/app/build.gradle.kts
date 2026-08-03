import java.io.FileInputStream
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

// BEGIN SALUMED RELEASE SIGNING
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
// END SALUMED RELEASE SIGNING

plugins {
    id("com.android.application")
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
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] =
            salumedGoogleMapsApiKey

        applicationId = "com.salumed.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (!keystorePropertiesFile.exists()) {
                throw GradleException(
                    "No existe android/key.properties. " +
                        "Crea ese archivo para firmar la versión release."
                )
            }

            val configuredKeyAlias =
                keystoreProperties.getProperty("keyAlias")

            val configuredKeyPassword =
                keystoreProperties.getProperty("keyPassword")

            val configuredStorePassword =
                keystoreProperties.getProperty("storePassword")

            val configuredStoreFile =
                keystoreProperties.getProperty("storeFile")

            if (configuredKeyAlias.isNullOrBlank()) {
                throw GradleException(
                    "Falta keyAlias en android/key.properties."
                )
            }

            if (configuredKeyPassword.isNullOrBlank()) {
                throw GradleException(
                    "Falta keyPassword en android/key.properties."
                )
            }

            if (configuredStorePassword.isNullOrBlank()) {
                throw GradleException(
                    "Falta storePassword en android/key.properties."
                )
            }

            if (configuredStoreFile.isNullOrBlank()) {
                throw GradleException(
                    "Falta storeFile en android/key.properties."
                )
            }

            keyAlias = configuredKeyAlias
            keyPassword = configuredKeyPassword
            storePassword = configuredStorePassword
            storeFile = file(configuredStoreFile)
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}