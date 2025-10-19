// services/api/Hyrox.Api/Data/AppDbContext.cs
using Microsoft.EntityFrameworkCore;

namespace Hyrox.Api.Data;   // <-- IMPORTANT: matches Program.cs `using Hyrox.Api.Data`

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<WorkoutSession> WorkoutSessions => Set<WorkoutSession>();
}

public class WorkoutSession
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string UserId { get; set; } = string.Empty;
    public string Routine { get; set; } = string.Empty;
    public DateTime StartedAtUtc { get; set; } = DateTime.UtcNow;
    public TimeSpan TotalTime { get; set; } = TimeSpan.Zero;
}