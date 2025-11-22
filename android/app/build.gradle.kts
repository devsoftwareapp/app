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

        // CRITICAL: CMake için ekle - DÜZELTİLDİ
        externalNativeBuild {
            cmake {
                cppFlags("-std=c++17", "-frtti", "-fexceptions")
                arguments("-DANDROID_STL=c++_shared")
            }
        }

        // CRITICAL: Native library için - DÜZELTİLDİ
        ndk {
            abiFilters.add("arm64-v8a")
            abiFilters.add("armeabi-v7a") 
            abiFilters.add("x86_64")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
        }
    }

    // CRITICAL: CMake build'ı aktif et - DÜZELTİLDİ
    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    // CRITICAL: Native library paketleme - DÜZELTİLDİ
    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
        resources {
            excludes += setOf(
                "META-INF/AL2.0",
                "META-INF/LGPL2.1",
                "**/libpdf_renderer.so"
            )
        }
        // ÖNEMLİ: STL kütüphanelerini paketle
        pickFirsts += setOf(
            "lib/arm64-v8a/libc++_shared.so",
            "lib/armeabi-v7a/libc++_shared.so", 
            "lib/x86_64/libc++_shared.so"
        )
    }

    buildFeatures {
        prefab = true
        buildConfig = true
    }

    // ÖNEMLİ: Build klasörünü temizle
    buildDir = file("build")
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
