import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    // It brings its own built-in Kotlin: kotlin-android must not be applied
    // here (migrate-to-built-in-kotlin). The KGP version pinned in
    // settings.gradle.kts stays only for the plugins that still need it.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload-key signing (Play App Signing). The keystore and its passwords live
// in android/key.properties, which is gitignored: no secret in the repo.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "fr.motzaique.mot_zaique"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Aligned with the JVM target of Flutter's built-in Kotlin (21):
        // a mismatch fails compileDebugKotlin.
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        // Identifiant enregistre par l'association dans la console Google
        // Play : definitif des la premiere publication, ne plus le changer.
        applicationId = "fr.motzaique.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Android 8.0 (API 26) minimum (CDC 5.3, confirme par l'association).
        // Ecarte notamment Android 7.0, dont le magasin de certificats ne
        // connait pas ISRG Root X1 (Let's Encrypt) -> ARASAAC y echoue.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let {
                file(it)
            }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // Signed with the association's upload key when key.properties is
            // present; falls back to the debug key so `flutter run --release`
            // still works on a machine without the keystore.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
