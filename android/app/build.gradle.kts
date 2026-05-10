import java.io.File
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google services plugin — required for Firebase
    id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")

/** Trims and strips optional quotes; Properties keys are case-sensitive so we allow common variants. */
fun Properties.signingValue(vararg keys: String): String? {
    for (key in keys) {
        val raw = getProperty(key) ?: continue
        val v = raw.trim().removeSurrounding("\"").removeSurrounding("'")
        if (v.isNotEmpty()) return v
    }
    for (name in stringPropertyNames()) {
        val match = keys.any { it.equals(name, ignoreCase = true) }
        if (!match) continue
        val raw = getProperty(name) ?: continue
        val v = raw.trim().removeSurrounding("\"").removeSurrounding("'")
        if (v.isNotEmpty()) return v
    }
    return null
}

val releaseSigning: Pair<File, Map<String, String>>? =
    if (!keystorePropertiesFile.exists()) {
        null
    } else {
        val p = Properties()
        keystorePropertiesFile.inputStream().use { p.load(it) }
        val storePath = p.signingValue("storeFile", "StoreFile")
            ?: throw GradleException(
                "android/key.properties: missing storeFile (use storeFile=..., e.g. ../upload-keystore.jks)",
            )
        val storeFile = rootProject.file(storePath)
        if (!storeFile.isFile) {
            throw GradleException(
                "android/key.properties: storeFile is not a file: ${storeFile.absolutePath}",
            )
        }
        val storePassword = p.signingValue("storePassword", "storepassword")
            ?: throw GradleException("android/key.properties: missing storePassword")
        val keyPassword = p.signingValue("keyPassword", "keypassword", "Keyword")
            ?: throw GradleException("android/key.properties: missing keyPassword")
        val keyAlias = p.signingValue("keyAlias", "KeyAlias")
            ?: throw GradleException("android/key.properties: missing keyAlias")
        storeFile to mapOf(
            "storePassword" to storePassword,
            "keyPassword" to keyPassword,
            "keyAlias" to keyAlias,
        )
    }

android {
    namespace = "com.chinulabs.reclaim"
    // compileSdk must be >= all Android plugins (current Flutter plugins expect 36).
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.chinulabs.reclaim"
        minSdk = maxOf(flutter.minSdkVersion, 24)
        // Google Play: new apps / updates must target API 35+ (Android 15) as of Aug 31, 2025.
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigning != null) {
            val (ksFile, secrets) = releaseSigning
            create("release") {
                keyAlias = secrets.getValue("keyAlias")
                keyPassword = secrets.getValue("keyPassword")
                storeFile = ksFile
                storePassword = secrets.getValue("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseSigning != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
