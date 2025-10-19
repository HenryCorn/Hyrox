var builder = DistributedApplication.CreateBuilder(args);

// Add PostgreSQL database
var postgres = builder.AddPostgres("postgres")
    .WithPgAdmin()
    .WithDataVolume();

var db = postgres.AddDatabase("hyroxdb");

// Add the API with database reference
var api = builder.AddProject<Projects.Hyrox_Api>("hyrox-api")
    .WithReference(db);

builder.Build().Run();

