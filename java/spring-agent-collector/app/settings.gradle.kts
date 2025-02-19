pluginManagement {
    plugins {
        id("com.diffplug.spotless") version "7.0.2"
        id("org.gradle.toolchains.foojay-resolver-convention") version "0.9.0"
    }
}

plugins {
    id("org.gradle.toolchains.foojay-resolver-convention")
}

rootProject.name = "spring-native-collector"
