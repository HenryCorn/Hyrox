namespace Hyrox.Api.DTOs;

public record SyncWorkoutRequest(
    /// <summary>Client-generated ID for idempotency (re-sending is safe).</summary>
    string ClientId,
    string RoutineName,
    DateTime CompletedAt,
    long TotalDurationMs,
    string SplitsJson,
    string RoxZoneSplitsJson,
    int? AvgHeartRate,
    double? TotalCalories
);

public record WorkoutResponse(
    Guid Id,
    string ClientId,
    string RoutineName,
    DateTime CompletedAtUtc,
    long TotalDurationMs,
    string SplitsJson,
    string RoxZoneSplitsJson,
    int? AvgHeartRate,
    double? TotalCalories
);
