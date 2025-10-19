# Hyrox.AppHost - .NET Aspire Application

This is the .NET Aspire AppHost project that orchestrates your Hyrox application.

## What is .NET Aspire?

.NET Aspire is an opinionated, cloud-ready stack for building observable, production-ready, distributed applications. It provides:

- **Orchestration**: Local development orchestration to run multiple projects and dependencies
- **Service Discovery**: Automatic service discovery between projects
- **Observability**: Built-in OpenTelemetry support for logs, traces, and metrics
- **Resilience**: HTTP resilience patterns built-in
- **Components**: Integration with databases, message queues, caching, and more

## Running the Application

To run your application with Aspire:

```bash
# From the solution root
cd services/Hyrox.AppHost
dotnet run
```

Or run directly from the solution root:

```bash
dotnet run --project services/Hyrox.AppHost/Hyrox.AppHost.csproj
```

This will start:
- **Hyrox.Api** - Your API service
- **PostgreSQL** - Database server (in a container)
- **pgAdmin** - PostgreSQL administration tool (in a container)
- **Aspire Dashboard** - Observability dashboard at `http://localhost:15888`

## Aspire Dashboard

Once running, open your browser to `http://localhost:15888` to see:

- **Resources**: All running services and their status
- **Console Logs**: Structured logs from all services
- **Traces**: Distributed tracing across services
- **Metrics**: Performance metrics and resource utilization

## What Was Added

### 1. Hyrox.AppHost
The orchestrator project that defines how services are connected and run together.

### 2. Hyrox.ServiceDefaults
Shared configuration for all Aspire services including:
- OpenTelemetry configuration
- Health checks
- Service discovery
- HTTP resilience patterns

### 3. Updated Hyrox.Api
Your API now:
- Uses Aspire service defaults
- Connects to PostgreSQL via Aspire integration
- Automatically exports telemetry to the Aspire dashboard
- Has health check endpoints at `/health` and `/alive`

## Connection Strings

Connection strings are automatically managed by Aspire. The database connection named "hyroxdb" in Program.cs is automatically mapped to the PostgreSQL instance orchestrated by the AppHost.

## Docker Requirements

Make sure Docker Desktop is running before starting the AppHost, as it will need to pull and run PostgreSQL and pgAdmin containers.

## Next Steps

1. Run the AppHost to see your application running
2. Explore the Aspire Dashboard to see telemetry
3. Add more services to Program.cs as your application grows
4. Consider adding Redis, RabbitMQ, or other Aspire components

## Learn More

- [.NET Aspire Documentation](https://learn.microsoft.com/dotnet/aspire/)
- [Aspire Components](https://learn.microsoft.com/dotnet/aspire/fundamentals/components-overview)

