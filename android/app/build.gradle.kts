plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")        // <- correcto en Kotlin DSL
    // El plugin de Flutter debe ir después de Android y Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.interfaz_usuario"   // AJUSTA si tu paquete cambia
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Narwhal: usa JDK 17
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.interfaz_usuario" // AJUSTA si corresponde
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            // Mientras desarrollas, firma de debug (cámbialo al publicar)
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            // Para publicar:
            // isMinifyEnabled = true
            // isShrinkResources = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
            // signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    // Firebase BoM (opcional, si usas Analytics u otros SDKs nativos)
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))
    implementation("com.google.firebase:firebase-analytics")

    // ❌ NO añadas el SDK de Facebook manualmente en Flutter.
    // El plugin `flutter_facebook_auth` ya aporta las dependencias correctas.
    // implementation("com.facebook.android:facebook-android-sdk:[4,5)")  // <- ELIMINADO
}

// Defensa extra por si otra lib arrastra Facebook 4.x:
configurations.all {
    resolutionStrategy.eachDependency {
        if (requested.group == "com.facebook.android") {
            useVersion("16.3.0")
            because("Evitar artefactos 4.x que rompen recursos (com_facebook_button_*).")
        }
    }
}

flutter {
    source = "../.."
}
