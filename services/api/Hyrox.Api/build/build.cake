// ====== Config ======
var target = Argument("target", "Default");
var configuration = Argument("configuration", "Release");

// Paths
var apiProj = "./services/api/Hyrox.Api/Hyrox.Api.csproj";
var apiDir  = "./services/api/Hyrox.Api";
var mobileDir = "./apps/mobile";
var artifactsDir = "./artifacts";
var swaggerOut = $"{artifactsDir}/swagger.json";
var genOutDir = $"{mobileDir}/lib/api_client"; // will be overwritten by generator

// URLs
var ApiBase = EnvironmentVariable("API_BASE") ?? "http://localhost:8080";
var SwaggerUrl = EnvironmentVariable("OPENAPI_URL") ?? $"{ApiBase}/swagger/v1/swagger.json";

// ====== Tasks ======
Task("Clean")
    .Does(() =>
{
    EnsureDirectoryExists(artifactsDir);
    CleanDirectory(artifactsDir);
    StartProcess("dotnet", $"clean {apiProj} -c {configuration}");
});

Task("Restore")
    .IsDependentOn("Clean")
    .Does(() => StartProcess("dotnet", $"restore {apiProj}"));

Task("Build")
    .IsDependentOn("Restore")
    .Does(() => StartProcess("dotnet", $"build {apiProj} -c {configuration} --no-restore"));

Task("Test")
    .Does(() =>
{
    // add test projects later; placeholder keeps pipeline shape
    Information("No test projects yet.");
});

Task("Publish")
    .IsDependentOn("Build")
    .Does(() => StartProcess("dotnet", $"publish {apiProj} -c {configuration} -o {artifactsDir}/api"));

Task("DockerBuild")
    .Does(() => StartProcess("docker", $"build -t hyrox-api:dev {apiDir}"));

Task("DockerUp")
    .Does(() =>
{
    StartProcess("docker", "compose up -d db");
    StartProcess("docker", "compose up -d api");
    // quick wait for API to boot
    StartProcess("bash", $"-lc \"for i in {{1..40}}; do curl -fsS {ApiBase}/healthz && exit 0; sleep 0.5; done; exit 1\"");
});

Task("DockerDown")
    .Does(() => StartProcess("docker", "compose down"));

Task("Migrate")
    .IsDependentOn("Build")
    .Does(() =>
{
    // Runs migrations against localhost DB. Ensure db is up (DockerUp) if needed.
    StartProcess("dotnet", $"ef database update --project {apiProj} --startup-project {apiProj}");
});

Task("OpenApi:Export")
    .Does(() =>
{
    EnsureDirectoryExists(artifactsDir);
    // API must be running (DockerUp or dotnet run)
    StartProcess("bash", $"-lc \"curl -fsS {SwaggerUrl} -o {swaggerOut}\"");
    Information($"Exported OpenAPI to {swaggerOut}");
});

Task("OpenApi:GenerateClient")
    .IsDependentOn("OpenApi:Export")
    .Does(() =>
{
    // Requires Docker and openapitools image
    // Generates a Dart client that uses dio into lib/api_client
    StartProcess("bash", $"-lc \"docker run --rm -v $PWD:/local openapitools/openapi-generator-cli generate " +
        $"-i /local/{swaggerOut} -g dart-dio -o /local/{genOutDir} --additional-properties=pubName=hyrox_api_client\"");
    Information($"Generated Dart client into {genOutDir}");
});

Task("Mobile:Analyze")
    .Does(() => StartProcess("bash", $"-lc \"cd {mobileDir} && flutter pub get && flutter analyze\""));

Task("Mobile:Test")
    .Does(() => StartProcess("bash", $"-lc \"cd {mobileDir} && flutter test\""));

// Convenience pipelines
Task("Dev:ApiLocal")
    .IsDependentOn("Build")
    .IsDependentOn("Migrate");

Task("Dev:Docker")
    .IsDependentOn("DockerBuild")
    .IsDependentOn("DockerUp");

Task("Client:Sync")
    .IsDependentOn("OpenApi:GenerateClient")
    .IsDependentOn("Mobile:Analyze");

// Default
Task("Default")
    .IsDependentOn("Build");

// ====== Run ======
RunTarget(target);
