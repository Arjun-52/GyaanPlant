allprojects {
    repositories {
        // Vendored Razorpay Android SDK (avoids Gradle/JBR TLS PKIX failures on some Windows setups).
        exclusiveContent {
            forRepository {
                maven {
                    name = "RazorpayLocal"
                    url = uri(rootProject.file("local-maven"))
                }
            }
            filter { includeGroup("com.razorpay") }
        }
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
