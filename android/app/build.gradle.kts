plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.devsoftware.pdf_reader_manager"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.devsoftware.pdf_reader_manager"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 🚨 C++ AYARLARI KALDIRILDI - artık gerek yok
        // externalNativeBuild {
        //     cmake {
        //         cppFlags += "-std=c++17"
        //         arguments += "-DANDROID_STL=c++_shared"
        //     }
        // }

        // 🚨 Native library ayarları kaldırıldı
        // ndk {
        //     abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a", "x86_64"))
        // }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // 🚨 CMake build kaldırıldı
    // externalNativeBuild {
    //     cmake {
    //         path = file("src/main/cpp/CMakeLists.txt")
    //         version = "3.22.1"
    //     }
    // }

    // 🚨 Native packaging kaldırıldı
    // packagingOptions {
    //     jniLibs {
    //         useLegacyPackaging = true
    //     }
    //     resources {
    //         excludes += "/META-INF/{AL2.0,LGPL2.1}"
    //     }
    // }

    // 🚨 Prefab kaldırıldı
    // buildFeatures {
    //     prefab = true
    // }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
}
