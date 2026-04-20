import java.util.Properties
import java.io.FileInputStream

// 1. قراءة بيانات ملف key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // يجب أن يكون بلجن فلاتر هو الأخير دائماً
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // تأكد أن هذا المعرف فريد لتطبيقك على المتجر
    namespace = "com.example.pregn_3"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // 2. إعدادات التوقيع (Signing Configuration)
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    defaultConfig {
        applicationId = "com.example.pregn_3"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 3. ربط نسخة الـ Release بملف الـ Keystore الذي عرفناه
            signingConfig = signingConfigs.getByName("release")
            
            // تحسينات اختيارية (تقليل حجم التطبيق)
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // مكتبة الماتيريال ديزاين
    implementation("com.google.android.material:material:1.12.0")
}