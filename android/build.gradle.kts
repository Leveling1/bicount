allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
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
