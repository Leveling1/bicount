allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val canonicalFlutterProjectDir = rootDir.parentFile.canonicalFile
val canonicalBuildDir = canonicalFlutterProjectDir.resolve("build")
rootProject.layout.buildDirectory.set(canonicalBuildDir)

subprojects {
    project.layout.buildDirectory.set(canonicalBuildDir.resolve(project.name))
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    configurations.configureEach {
        resolutionStrategy.force(
            "androidx.core:core:1.15.0",
            "androidx.core:core-ktx:1.15.0",
            "androidx.activity:activity:1.10.1",
            "androidx.activity:activity-ktx:1.10.1",
            "androidx.browser:browser:1.8.0",
        )
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
