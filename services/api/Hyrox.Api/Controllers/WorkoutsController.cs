using System.Security.Claims;
using Hyrox.Api.Data;
using Hyrox.Api.DTOs;
using Hyrox.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Hyrox.Api.Controllers;

[ApiController]
[Route("api/workouts")]
[Authorize]
public sealed class WorkoutsController(AppDbContext db, ILogger<WorkoutsController> logger) : ControllerBase
{
    /// <summary>Idempotent upsert — safe to call multiple times with the same ClientId.</summary>
    [HttpPost]
    [ProducesResponseType<WorkoutResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Sync([FromBody] SyncWorkoutRequest request, CancellationToken ct)
    {
        var userId = GetUserId();

        var existing = await db.WorkoutSessions
            .FirstOrDefaultAsync(w => w.UserId == userId && w.ClientId == request.ClientId, ct);

        if (existing is not null)
            return Ok(existing.ToDto()); // already synced — idempotent

        var session = new WorkoutSession
        {
            UserId = userId,
            ClientId = request.ClientId,
            RoutineName = request.RoutineName,
            CompletedAtUtc = request.CompletedAt.ToUniversalTime(),
            TotalDurationMs = request.TotalDurationMs,
            SplitsJson = request.SplitsJson,
            RoxZoneSplitsJson = request.RoxZoneSplitsJson,
            AvgHeartRate = request.AvgHeartRate,
            TotalCalories = request.TotalCalories,
        };

        db.WorkoutSessions.Add(session);
        await db.SaveChangesAsync(ct);

        logger.LogInformation("Synced workout {ClientId} for user {UserId}", request.ClientId, userId);
        return Ok(session.ToDto());
    }

    [HttpGet]
    [ProducesResponseType<List<WorkoutResponse>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> List(
        [FromQuery] int limit = 50,
        [FromQuery] long? beforeMs = null,
        CancellationToken ct = default)
    {
        var userId = GetUserId();

        var query = db.WorkoutSessions
            .Where(w => w.UserId == userId);

        if (beforeMs.HasValue)
        {
            var before = DateTimeOffset.FromUnixTimeMilliseconds(beforeMs.Value).UtcDateTime;
            query = query.Where(w => w.CompletedAtUtc < before);
        }

        var sessions = await query
            .OrderByDescending(w => w.CompletedAtUtc)
            .Take(Math.Clamp(limit, 1, 200))
            .ToListAsync(ct);

        return Ok(sessions.Select(s => s.ToDto()).ToList());
    }

    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        var userId = GetUserId();
        var session = await db.WorkoutSessions
            .FirstOrDefaultAsync(w => w.Id == id && w.UserId == userId, ct);

        if (session is null) return NotFound();

        db.WorkoutSessions.Remove(session);
        await db.SaveChangesAsync(ct);
        return NoContent();
    }

    private Guid GetUserId()
    {
        var raw = User.FindFirstValue("uid")
            ?? throw new InvalidOperationException("uid claim missing.");
        return Guid.Parse(raw);
    }
}

file static class WorkoutExtensions
{
    internal static WorkoutResponse ToDto(this WorkoutSession s) => new(
        s.Id, s.ClientId, s.RoutineName, s.CompletedAtUtc,
        s.TotalDurationMs, s.SplitsJson, s.RoxZoneSplitsJson,
        s.AvgHeartRate, s.TotalCalories
    );
}
