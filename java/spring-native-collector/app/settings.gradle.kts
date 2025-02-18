pluginManagement {
    plugins {
        id("com.diffplug.spotless") version "7.0.2"
        id("com.github.johnrengelman.shadow") version "8.1.1"
        id("com.google.protobuf") version "0.9.4"
        id("org.gradle.toolchains.foojay-resolver-convention") version "0.9.0"
        id("com.google.cloud.tools.jib") version "3.4.4"
        id("com.gradle.develocity") version "3.19.1"
    }
}

plugins {
    id("org.gradle.toolchains.foojay-resolver-convention")
    id("com.gradle.develocity")
}

develocity {
    buildScan {
        publishing.onlyIf { System.getenv("CI") != null }
        termsOfUseUrl.set("https://gradle.com/help/legal-terms-of-use")
        termsOfUseAgree.set("yes")
    }
}

rootProject.name = "opentelemetry-java-examples"
include(
    ":opentelemetry-examples-spring-native",
)

rootProject.children.forEach {
    if (it.name != "doc-snippets") {
        it.projectDir = file(
          "$rootDir/${it.name}".replace("opentelemetry-examples-", "")
        )
    }
}
