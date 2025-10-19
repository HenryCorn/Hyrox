# Git Commit Guide for Hyrox Project

## ✅ Files You SHOULD Commit (Currently Staged)

### Source Code & Configuration
- **.gitignore** - Updated with .NET and Aspire rules
- **Hyrox.sln** - Solution file with new Aspire projects
- **services/Hyrox.AppHost/** - New Aspire orchestrator project
  - Hyrox.AppHost.csproj
  - Program.cs
  - appsettings.json (base config only)
  - Properties/launchSettings.json
  - README.md
- **services/Hyrox.ServiceDefaults/** - Shared Aspire configuration
  - Hyrox.ServiceDefaults.csproj
  - Extensions.cs
- **services/api/Hyrox.Api/** - Your API project
  - Hyrox.Api.csproj (updated)
  - Program.cs (updated)
  - appsettings.json (base config only)
  - Data/*.cs (your DbContext and models)
  - Any other source files

## ❌ Files You SHOULD NOT Commit (Now Ignored)

### Build Artifacts
- **bin/** folders - Compiled binaries (.dll, .exe, .pdb)
- **obj/** folders - Build cache and intermediate files
- All **\*.dll**, **\*.pdb**, **\*.exe** files

### Generated Files
- **\*.AssemblyInfo.cs** - Auto-generated assembly metadata
- **\*.AssemblyInfoInputs.cache** - Build cache
- **\*.assets.cache** - NuGet asset cache
- **\*.GeneratedMSBuildEditorConfig.editorconfig** - Auto-generated config
- **\*GlobalUsings.g.cs** - Auto-generated using statements
- **\*.sourcelink.json** - Source linking metadata
- **project.assets.json** - NuGet lock file
- **project.nuget.cache** - NuGet cache
- **\*.csproj.nuget.\*** - NuGet props and targets
- **rider.project.\*.info** - JetBrains Rider cache

### Environment-Specific Config
- **appsettings.Development.json** - Local development settings (may contain secrets)
- **appsettings.\*.json** - Any environment-specific settings
- **secrets.json** - User secrets
- **\*.pfx, \*.p12** - Certificates

### IDE & Tools
- **.vs/** - Visual Studio cache
- **.idea/** - JetBrains Rider/IntelliJ cache
- **\*.user** - User-specific IDE settings
- **\*.suo** - Visual Studio solution options

## 📝 Current Status

Your staging area now contains **ONLY** the files you should commit:
- 2 modified files (.gitignore, Hyrox.sln)
- 9 new files (Aspire projects and their source files)

All build artifacts (30+ files in bin/obj folders) are now properly ignored and won't be committed.

## 🚀 Ready to Commit

You can now safely commit your changes:

```bash
git commit -m "Add .NET Aspire orchestration with AppHost and ServiceDefaults

- Add Hyrox.AppHost project for Aspire orchestration
- Add Hyrox.ServiceDefaults for shared configuration
- Update Hyrox.Api to use Aspire service defaults
- Configure PostgreSQL and pgAdmin via Aspire
- Update .gitignore for .NET and Aspire artifacts
- Enable Swagger UI in development mode"
```

## 📚 Why This Matters

**Build artifacts should never be in source control because:**
1. They're generated from source code
2. They differ between machines and environments
3. They bloat repository size
4. They cause merge conflicts
5. CI/CD systems rebuild them anyway

**Only commit source files that:**
1. Are written by developers (not tools)
2. Are needed to build the project
3. Define configuration or infrastructure

