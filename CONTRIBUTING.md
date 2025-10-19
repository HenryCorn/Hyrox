# Contributing to Hyrox

Thanks for your interest in contributing! This doc explains how to set up your environment, the workflow, and our conventions.

## TL;DR

- Branch from `develop` → `feature/<short-name>`
- Keep PRs small and focused
- Run checks locally before opening a PR:
    - API: `dotnet build` (and tests when added)
    - Mobile: `flutter analyze && flutter test`
    - Cake targets where applicable
- Add/update OpenAPI + regenerate the Dart client when API contracts change

---

## Project Layout

```
apps/mobile            # Flutter app
services/api/Hyrox.Api # .NET API
build/build.cake       # Cake build script
docker-compose.yml     # Local DB+API
artifacts/             # Generated artifacts (swagger.json, publish outputs)
```

## Prerequisites

- Flutter (stable)
- .NET SDK (8 or 9 matching project)
- Docker Desktop (Compose v2)
- Cake.Tool (`dotnet tool install Cake.Tool`)
- Optional: OpenAPI Generator Docker image (`openapitools/openapi-generator-cli`)

## Branching & Workflow

1. Create a branch from `develop`:
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/<short-name>
   ```
2. Commit often, keep changesets focused.
3. Open a PR into `develop` when ready.
4. Request review and address comments.
5. Squash-merge after approval.

## Commit Messages

Use clear, imperative messages. Conventional commits encouraged:
- `feat(api): add POST /workouts`
- `fix(mobile): correct timer pause bug`
- `chore(ci): add mobile workflow`

## Style & Quality

- **API (.NET)**
    - Nullable enabled, warnings-as-errors recommended
    - Minimal APIs or Controllers OK
    - Logging with Serilog; structured logs
    - EF Core migrations kept in `Hyrox.Api`
    - Tests (xUnit) under `tests/` (to be added)

- **Mobile (Flutter)**
    - Use Riverpod (or chosen SM) for state
    - Lints clean: `flutter analyze`
    - Unit & widget tests for core flows
    - Keep generated code (`lib/api_client`) in sync with OpenAPI

## Running Locally

- **API + DB via Docker**
  ```bash
  dotnet cake build/build.cake --target=Dev:Docker
  # API: http://localhost:8080/swagger
  ```

- **Generate Dart client (needs API running)**
  ```bash
  dotnet cake build/build.cake --target=Client:Sync
  ```

- **Flutter app**
  ```bash
  cd apps/mobile
  flutter pub get
  flutter run
  ```

## Updating API Contracts

1. Modify endpoints & data contracts.
2. Export OpenAPI & regenerate client:
   ```bash[pull_request_template.md](.github/pull_request_template.md)
   dotnet cake build/build.cake --target=Client:Sync
   ```
3. Update mobile code to use the new client.

## Pull Requests

- Include a concise description (What/Why/How to test)
- Screenshots/GIFs for UI changes are very helpful
- Ensure CI is green (API + mobile workflows)
- If the API changed, confirm the Dart client was regenerated

## Code of Conduct

Be respectful and constructive. No harassment, personal attacks, or discrimination.

## Licensing

By contributing, you agree your contributions are licensed under this repository’s license.
