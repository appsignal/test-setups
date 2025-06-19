import org.springframework.boot.gradle.plugin.SpringBootPlugin

plugins {
    id("java")
    id("org.springframework.boot") version "3.4.2"
    id("org.graalvm.buildtools.native") version "0.10.5"
    id("com.diffplug.spotless") version "7.0.2"
}

group = "io.opentelemetry"
version = "0.1.0-SNAPSHOT"
description = "OpenTelemetry Example for Spring native images"

repositories {
    mavenCentral()
}

dependencies {
    implementation(platform(SpringBootPlugin.BOM_COORDINATES))
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jdbc")
    implementation("com.h2database:h2")
    implementation("io.opentelemetry:opentelemetry-api")
}

spotless {
    java {
        targetExclude("**/generated/**")
        googleJavaFormat()
    }
}

tasks.bootRun {
    if (project.hasProperty("jvmargs")) {
        jvmArgs = (project.property("jvmargs") as String).split("\\s+".toRegex())
    }
    if (project.hasProperty("args")) {
        args = (project.property("args") as String).split("\\s+".toRegex())
    }
}
