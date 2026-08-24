import java.net.URI
import java.nio.charset.StandardCharsets
import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val decodedDartDefines = (project.findProperty("dart-defines") as String?)
    ?.split(',')
    ?.mapNotNull { encoded ->
        runCatching {
            String(Base64.getDecoder().decode(encoded), StandardCharsets.UTF_8)
        }.getOrNull()
    }
    ?.mapNotNull { definition ->
        val separator = definition.indexOf('=')
        if (separator <= 0) null
        else definition.substring(0, separator) to definition.substring(separator + 1)
    }
    ?.toMap()
    .orEmpty()

val customerAccountRedirectScheme = decodedDartDefines[
    "SHOPIFY_CUSTOMER_ACCOUNT_REDIRECT_URI"
]
    ?.let { redirectUri -> runCatching { URI(redirectUri).scheme }.getOrNull() }
    ?.let { scheme -> if (scheme != null && scheme.startsWith("shop.")) scheme else null }
    ?: "shop.customer-account.unconfigured"

android {
    namespace = "com.rebornpackaging.reborn_packaging"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rebornpackaging.reborn_packaging"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appAuthRedirectScheme"] = customerAccountRedirectScheme
    }

    buildTypes {
        release {
            // Configure a private upload/release key outside source control before shipping.
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
    implementation("com.shopify:checkout-sheet-kit:3.6.0")
}
