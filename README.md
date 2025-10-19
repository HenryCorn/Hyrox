# Hyrox – Cross-Platform Hyrox Workout Tracker

A cross-platform mobile app (Flutter) + .NET Web API to track Hyrox workouts with predefined routines, timers, Apple Watch (HealthKit) support, social features, and freemium monetization. Built with clean architecture, testing, tracing, and CI/CD in mind.

## Tech Stack

- **Mobile:** Flutter (Dart), Riverpod, Dio (OpenAPI-generated client)
- **API:** .NET 8/9 Minimal API, EF Core (PostgreSQL), Serilog, OpenTelemetry
- **Contracts:** OpenAPI (Swashbuckle)
- **Build/CI:** Cake, GitHub Actions
- **Runtime (local):** Docker Compose (API + Postgres)
- **Auth (later MVP):** Firebase Auth (Google/Apple)
- **Crash/Analytics (mobile):** Crashlytics (later)
- **Monetization (later):** AdMob + RevenueCat

---

## Repo Structure

```
.
├── apps/
│   └── mobile/                 # Flutter app
├── services/
│   └── api/
│       └── Hyrox.Api/          # .NET Web API (Minimal API)
├── build/
│   └── build.cake              # Cake script (build, docker, openapi, generate client)
├── artifacts/                  # (generated) Swagger, publish outputs, etc.
├── docker-compose.yml
├── README.md
└── .github/workflows/          # CI (API & Mobile)
```

---

## Prerequisites

- **Flutter** (stable) – `flutter --version`
- **.NET SDK** 8.0 or 9.0 (match your project/Dockerfile) – `dotnet --version`
- **Docker Desktop** (Compose v2) – `docker --version`
- **Node not required**
- **Cake.Tool** (auto-installed via `dotnet tool`)  
  *(We run Cake via `dotnet cake`)*

> If targeting **.NET 9**, ensure Dockerfile uses `mcr.microsoft.com/dotnet/sdk:9.0` and `aspnet:9.0`.

---

## Quick Start

### 1) Clone & setup tools

```bash
git clone <your-repo-url>
cd Hyrox

# (First time) initialize Cake tool manifest
dotnet new tool-manifest
dotnet tool install Cake.Tool
```

### 2) Run the API + DB with Docker

```bash
# from repo root
dotnet cake build/build.cake --target=Dev:Docker
# Waits until API is healthy

# API:
#   http://localhost:8080/healthz
#   http://localhost:8080/swagger
```

> If you prefer local run without Docker:  
> `cd services/api/Hyrox.Api && dotnet run`  
> Swagger at `http://localhost:<kestrel-port>/swagger`

### 3) Generate the Dart API client from OpenAPI

```bash
# with API running (Docker or dotnet run)
dotnet cake build/build.cake --target=Client:Sync
# -> artifacts/swagger.json
# -> apps/mobile/lib/api_client (overwritten)
```

### 4) Run the Flutter app

```bash
cd apps/mobile
flutter pub get
flutter run
```

---

## Common Tasks (Cake)

From **repo root**:

```bash
# build API
dotnet cake build/build.cake --target=Build

# run DB+API in Docker (and wait for /healthz)
dotnet cake build/build.cake --target=Dev:Docker

# export OpenAPI and generate Dart client
dotnet cake build/build.cake --target=Client:Sync

# apply EF migrations to local Postgres (localhost)
dotnet cake build/build.cake --target=Migrate

# stop containers
dotnet cake build/build.cake --target=DockerDown
```

Environment knobs:

```bash
# Use different API base when exporting OpenAPI (default http://localhost:8080)
API_BASE=http://localhost:5254 \
dotnet cake build/build.cake --target=Client:Sync

# Or point directly to a doc URL
OPENAPI_URL=http://localhost:8080/openapi/v1.json \
dotnet cake build/build.cake --target=Client:Sync
```

---

## EF Core (PostgreSQL)

**Connection strings**
- **Local (host):** `Host=localhost;Database=hyrox;Username=hyrox;Password=hyrox`
- **In Docker:** `Host=db;Database=hyrox;Username=hyrox;Password=hyrox`

**Files**
- `services/api/Hyrox.Api/Data/AppDbContext.cs`
- `services/api/Hyrox.Api/Data/HyroxDesignTimeDbContextFactory.cs`

**Migrations & DB update**
```bash
cd services/api/Hyrox.Api

# add a migration
dotnet ef migrations add <Name>

# update local database (ensure Postgres is running on localhost:5432)
dotnet ef database update
```

> If EF tooling can’t find your context, ensure the design-time factory exists and you’re running from the **Hyrox.Api** project directory (or pass `--project`/`--startup-project`).

---

## Docker

**docker-compose.yml** (root) runs:
- `db` (Postgres 16)
- `api` (Hyrox.Api on port 8080)

Commands:
```bash
docker compose up -d db
docker compose up -d api
docker compose logs -f api
docker compose down
```

If builds are slow, try BuildKit bake:
```bash
COMPOSE_BAKE=true docker compose build
```

---

## OpenAPI

- Served by API at `/swagger/v1/swagger.json` (Swashbuckle)
- (If using .NET 8 `AddOpenApi`): JSON at `/openapi/v1.json` – point Swagger UI to that.

**Regenerate client**
```bash
dotnet cake build/build.cake --target=Client:Sync
```
This uses the **OpenAPI Generator** Docker image and outputs a **Dio** client to:
`apps/mobile/lib/api_client`.

---

## Mobile App (Flutter)

Key packages (initial):
- `riverpod` / `flutter_riverpod`
- `dio`
- `freezed` + `json_serializable` (optional for models)

The generated API client lives in `lib/api_client`. Inject a configured `Dio(baseUrl: <api>)` and call the generated services.

Run:
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

---

## Configuration & Environments

**API**
- `appsettings.Development.json` – local dev
- Environment variables (Docker Compose) override:
    - `ConnectionStrings__Default=Host=db;Database=hyrox;Username=hyrox;Password=hyrox`
    - `ASPNETCORE_ENVIRONMENT=Development`

**Cake**
- `API_BASE` / `OPENAPI_URL` to control where to fetch OpenAPI from.

---

## Troubleshooting

- **Blank `/swagger` page**  
  Add Swashbuckle in `Program.cs`:
  ```csharp
  builder.Services.AddEndpointsApiExplorer();
  builder.Services.AddSwaggerGen();
  if (app.Environment.IsDevelopment()) { app.UseSwagger(); app.UseSwaggerUI(); }
  ```
  If you used `.AddOpenApi()`, also call `app.MapOpenApi()` or point Swagger UI to `/openapi/v1.json`.

- **HTTPS redirect loop in dev**  
  Comment out `app.UseHttpsRedirection()` if only HTTP is listening.

- **Compose path errors**  
  Run `docker compose` from **repo root** (build context paths are relative to root).

- **`.NET 9` vs Docker SDK mismatch**  
  If project targets `net9.0`, use `mcr.microsoft.com/dotnet/sdk:9.0` and `aspnet:9.0` in Dockerfile (or downgrade to `net8.0`).

- **EF “migrations assembly” error**  
  Add `HyroxDesignTimeDbContextFactory` and run `dotnet ef` from `services/api/Hyrox.Api`.

- **Postgres connection refused**  
  `docker compose up -d db`  
  Check port: `nc -zv localhost 5432`

---

## Roadmap (MVPs)

- **MVP1:** Offline routines + timer UI (start/pause/next/restart), summary.
- **MVP2:** Auth (Google/Apple via Firebase), history & stats, GDPR (delete account), OpenTelemetry, Crashlytics.
- **MVP3:** Apple HealthKit (HR + calories) live in workout & persisted summary.
- **MVP4:** Friends, tagging, leaderboards, compare sessions.
- **MVP5:** Share to Instagram (generated image, branded).
- **MVP6:** Monetization (AdMob + RevenueCat), premium charts/export, onboarding & polish.

---

## Scripts/Cheatsheet

```bash
# Build API
dotnet cake build/build.cake --target=Build

# Run DB+API in Docker
dotnet cake build/build.cake --target=Dev:Docker

# Export OpenAPI & generate Dart client
dotnet cake build/build.cake --target=Client:Sync

# Apply migrations locally
dotnet cake build/build.cake --target=Migrate

# Run Flutter app
cd apps/mobile && flutter run
```

---

## Contributing

- Branch off `develop`, open PRs to `develop`
- Run `flutter analyze` + `dotnet build` + Cake `Build` before PR
- Keep commits scoped and descriptive

---

## License

MIT (or your choice). Add a `LICENSE` file if publishing publicly.
