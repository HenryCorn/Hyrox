
// #addin nuget:https://api.nuget.org/v3/index.json?package=Cake.GitVersion
// #tool "dotnet:?package=GitVersion.Tool&version=5.12.0"

// Arguments
var target = Argument("target", "Default");
var configuration = Argument("configuration", "Release");
var dockerRegistry = Argument("registry", "ghcr.io/henrycorn");
var apiBase = Argument("api_base", EnvironmentVariable("API_BASE") ?? "http://localhost:8080");

// Paths
var apiProject = "../services/api/Hyrox.Api/Hyrox.Api.csproj";
var artifactsDir = "../artifacts";
var apiArtifactsDir = $"{artifactsDir}/api";
var openApiSpecPath = $"{artifactsDir}/swagger.json";
var mobileApiClientDir = "../apps/mobile/lib/api_client";

Task("Clean")
    .Does(() => {
        CleanDirectories(new[] { artifactsDir, apiArtifactsDir });
        StartProcess("dotnet", $"clean {apiProject}");
    });

Task("Restore")
    .Does(() => StartProcess("dotnet", $"restore {apiProject}"));

Task("Build")
    .IsDependentOn("Clean")
    .IsDependentOn("Restore")
    .Does(() => StartProcess("dotnet", $"build {apiProject} -c {configuration}"));

Task("Test")
    .IsDependentOn("Build")
    .Does(() => StartProcess("dotnet", $"test {apiProject} --no-build"));

Task("Publish")
    .IsDependentOn("Test")
    .Does(() => StartProcess("dotnet", $"publish {apiProject} -c {configuration} -o {apiArtifactsDir}"));

Task("DockerBuild")
    .IsDependentOn("Publish")
    .Does(() => {
        var version = "0.0.1"; // GitVersion().SemVer;
        StartProcess("docker", $"build -t {dockerRegistry}/hyrox-api:{version} -t {dockerRegistry}/hyrox-api:latest ./services/api/Hyrox.Api");
    });

Task("DockerPush")
    .IsDependentOn("DockerBuild")
    .Does(() => {
        var version = "0.0.1"; // GitVersion().SemVer;
        StartProcess("docker", $"push {dockerRegistry}/hyrox-api:{version}");
        StartProcess("docker", $"push {dockerRegistry}/hyrox-api:latest");
    });

Task("OpenApi:Export")
    .Does(() => {
        EnsureDirectoryExists(artifactsDir);
        StartProcess("curl", $"-sS {apiBase}/swagger/v1/swagger.json -o {openApiSpecPath}");
    });

Task("OpenApi:GenerateClient")
    .IsDependentOn("OpenApi:Export")
    .Does(() => {
        // Use OpenAPI Generator Docker image to generate Dart client
        StartProcess("docker", new ProcessSettings {
            Arguments = $"run --rm -v {System.IO.Path.GetFullPath(artifactsDir)}:/local -v {System.IO.Path.GetFullPath(mobileApiClientDir)}:/output " +
                       "openapitools/openapi-generator-cli:v7.0.0 generate " +
                       "-i /local/swagger.json " +
                       "-g dart-dio " +
                       "-o /output " +
                       "--additional-properties=pubName=hyrox_api_client,pubVersion=1.0.0"
        });
    });

Task("Default")
    .IsDependentOn("Test");



Task("Dev:Docker")
    .Does(() => {
        StartProcess("docker", "compose up -d");
        // Wait for health check?
        // For now just start it.
    });

Task("DockerDown")
    .Does(() => {
        StartProcess("docker", "compose down");
    });

RunTarget(target);
