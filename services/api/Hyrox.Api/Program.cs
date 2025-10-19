using Hyrox.Api.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();
builder.Services.AddOpenApi(); 
builder.Services.AddDbContext<AppDbContext>(o =>
    o.UseNpgsql(builder.Configuration.GetConnectionString("Default")));


var app = builder.Build();

app.MapHealthChecks("/healthz");

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi(); 
    app.UseSwagger();              // serves /swagger/v1/swagger.json
    app.UseSwaggerUI(c =>
    {
        // Point the UI to the new endpoint
        c.SwaggerEndpoint("/openapi/v1.json", "Hyrox API v1");
        c.RoutePrefix = "swagger";      // UI at /swagger
    });         // serves /swagger
}

// Optional in dev: comment out to avoid redirecting to HTTPS if you don't have an HTTPS endpoint
// app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast(
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        )
    ).ToArray();
    return forecast;
});

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}