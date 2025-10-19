## What

<!-- Briefly describe the change -->

## Why

<!-- Why is this change needed? Link issues if applicable -->

## How to test

- [ ] API: `dotnet build` (and tests if present)
- [ ] Docker API+DB: `dotnet cake build/build.cake --target=Dev:Docker`
- [ ] OpenAPI export + client generation (if API changed): `dotnet cake build/build.cake --target=Client:Sync`
- [ ] Mobile: `flutter analyze && flutter test && flutter run`

## Screenshots / Recordings

<!-- UI changes? Add screenshots or short clips -->

## Checklist

- [ ] Small, focused PR
- [ ] OpenAPI updated (if applicable)
- [ ] Dart client regenerated (if applicable)
- [ ] Migrations added & applied locally (if applicable)
- [ ] Docs/README updated (if needed)
