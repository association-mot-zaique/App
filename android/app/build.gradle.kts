plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    // It brings its own built-in Kotlin: kotlin-android must not be applied
    // here (migrate-to-built-in-kotlin). The KGP version pinned in
    // settings.gradle.kts stays only for the plugins that still need it.
    id("dev.flutter.flutter-gradle-plugin")
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
        applicationId = "fr.motzaique.mot_zaique"
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

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
