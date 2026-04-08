namespace Hyrox.Api.Models;

public class WorkoutSession
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UserId { get; set; }
    public AppUser User { get; set; } = null!;

    public string RoutineName { get; set; } = string.Empty;

    public DateTime CompletedAtUtc { get; set; }

    /// <summary>Total workout duration in milliseconds.</summary>
    public long TotalDurationMs { get; set; }

    /// <summary>JSON array of per-exercise split durations in milliseconds.</summary>
    public string SplitsJson { get; set; } = "[]";

    /// <summary>JSON array of Rox Zone transition durations in milliseconds.</summary>
    public string RoxZoneSplitsJson { get; set; } = "[]";

    public int? AvgHeartRate { get; set; }
    public double? TotalCalories { get; set; }

    /// <summary>
    /// Client-assigned ID used for idempotent upserts (prevents duplicates when
    /// syncing the same workout from multiple devices or after a retry).
    /// </summary>
    public string ClientId { get; set; } = string.Empty;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
