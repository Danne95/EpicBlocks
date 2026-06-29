plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystorePath = System.getenv("ANDROID_RELEASE_KEYSTORE_PATH")
val releaseStorePassword = System.getenv("ANDROID_RELEASE_STORE_PASSWORD")
val releaseKeyPassword = System.getenv("ANDROID_RELEASE_KEY_PASSWORD")
val releaseKeyAlias = System.getenv("ANDROID_RELEASE_KEY_ALIAS")
val hasReleaseSigning = releaseKeystorePath != null &&
    releaseStorePassword != null &&
    releaseKeyPassword != null &&
    releaseKeyAlias != null

android {
    namespace = "com.epicplay.epicblocks"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.epicplay.epicblocks"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                storeFile = file(releaseKeystorePath!!)
                storePassword = releaseStorePassword
                keyPassword = releaseKeyPassword
                keyAlias = releaseKeyAlias
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
}
