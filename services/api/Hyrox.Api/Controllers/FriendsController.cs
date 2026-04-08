using System.Security.Claims;
using Hyrox.Api.Data;
using Hyrox.Api.DTOs;
using Hyrox.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Hyrox.Api.Controllers;

[ApiController]
[Route("api/friends")]
[Authorize]
public sealed class FriendsController(AppDbContext db, ILogger<FriendsController> logger) : ControllerBase
{
    // ── GET /api/friends ──────────────────────────────────────────────────────
    [HttpGet]
    [ProducesResponseType<List<FriendResponse>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> List(CancellationToken ct)
    {
        var userId = GetUserId();

        var friendships = await db.Friendships
            .Include(f => f.Requester)
            .Include(f => f.Addressee)
            .Where(f =>
                f.Status == FriendshipStatus.Accepted &&
                (f.RequesterId == userId || f.AddresseeId == userId))
            .OrderByDescending(f => f.UpdatedAtUtc)
            .ToListAsync(ct);

        var results = friendships.Select(f =>
        {
            var friend = f.RequesterId == userId ? f.Addressee : f.Requester;
            return new FriendResponse(f.Id, friend.ToDto(), f.UpdatedAtUtc);
        }).ToList();

        return Ok(results);
    }

    // ── GET /api/friends/requests ─────────────────────────────────────────────
    [HttpGet("requests")]
    [ProducesResponseType<List<FriendRequestResponse>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> ListRequests(CancellationToken ct)
    {
        var userId = GetUserId();

        var pending = await db.Friendships
            .Include(f => f.Requester)
            .Where(f => f.AddresseeId == userId && f.Status == FriendshipStatus.Pending)
            .OrderByDescending(f => f.CreatedAtUtc)
            .ToListAsync(ct);

        return Ok(pending.Select(f =>
            new FriendRequestResponse(f.Id, f.Requester.ToDto(), f.CreatedAtUtc)).ToList());
    }

    // ── POST /api/friends/requests ────────────────────────────────────────────
    [HttpPost("requests")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> SendRequest([FromBody] SendFriendRequestRequest request, CancellationToken ct)
    {
        var userId = GetUserId();

        if (userId == request.AddresseeId)
            return BadRequest(new { error = "Cannot send a friend request to yourself." });

        // Check addressee exists
        var addresseeExists = await db.Users.AnyAsync(u => u.Id == request.AddresseeId, ct);
        if (!addresseeExists) return NotFound(new { error = "User not found." });

        // Check for existing friendship in either direction
        var existing = await db.Friendships.FirstOrDefaultAsync(f =>
            (f.RequesterId == userId && f.AddresseeId == request.AddresseeId) ||
            (f.RequesterId == request.AddresseeId && f.AddresseeId == userId), ct);

        if (existing is not null)
        {
            if (existing.Status == FriendshipStatus.Accepted)
                return Conflict(new { error = "Already friends." });
            if (existing.Status == FriendshipStatus.Pending)
                return Conflict(new { error = "Friend request already pending." });

            // Re-activate a previously declined request
            existing.Status = FriendshipStatus.Pending;
            existing.RequesterId = userId;
            existing.AddresseeId = request.AddresseeId;
            existing.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
            return Ok(new { friendshipId = existing.Id });
        }

        var friendship = new Friendship
        {
            RequesterId = userId,
            AddresseeId = request.AddresseeId,
        };
        db.Friendships.Add(friendship);
        await db.SaveChangesAsync(ct);

        logger.LogInformation("Friend request {Id} sent from {From} to {To}",
            friendship.Id, userId, request.AddresseeId);

        return Ok(new { friendshipId = friendship.Id });
    }

    // ── PUT /api/friends/requests/{id}/accept ─────────────────────────────────
    [HttpPut("requests/{id:guid}/accept")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Accept(Guid id, CancellationToken ct)
    {
        var userId = GetUserId();
        var friendship = await db.Friendships
            .FirstOrDefaultAsync(f => f.Id == id && f.AddresseeId == userId
                                   && f.Status == FriendshipStatus.Pending, ct);

        if (friendship is null) return NotFound();

        friendship.Status = FriendshipStatus.Accepted;
        friendship.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return NoContent();
    }

    // ── PUT /api/friends/requests/{id}/decline ────────────────────────────────
    [HttpPut("requests/{id:guid}/decline")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Decline(Guid id, CancellationToken ct)
    {
        var userId = GetUserId();
        var friendship = await db.Friendships
            .FirstOrDefaultAsync(f => f.Id == id && f.AddresseeId == userId
                                   && f.Status == FriendshipStatus.Pending, ct);

        if (friendship is null) return NotFound();

        friendship.Status = FriendshipStatus.Declined;
        friendship.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return NoContent();
    }

    // ── DELETE /api/friends/{id} ──────────────────────────────────────────────
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Remove(Guid id, CancellationToken ct)
    {
        var userId = GetUserId();
        var friendship = await db.Friendships
            .FirstOrDefaultAsync(f =>
                f.Id == id &&
                (f.RequesterId == userId || f.AddresseeId == userId) &&
                f.Status == FriendshipStatus.Accepted, ct);

        if (friendship is null) return NotFound();

        db.Friendships.Remove(friendship);
        await db.SaveChangesAsync(ct);
        return NoContent();
    }

    // ── GET /api/friends/{friendId}/workouts ──────────────────────────────────
    [HttpGet("{friendId:guid}/workouts")]
    [ProducesResponseType<List<WorkoutResponse>>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> FriendWorkouts(Guid friendId,
        [FromQuery] int limit = 20, CancellationToken ct = default)
    {
        var userId = GetUserId();

        // Ensure they are actually friends
        var areFriends = await db.Friendships.AnyAsync(f =>
            f.Status == FriendshipStatus.Accepted &&
            ((f.RequesterId == userId && f.AddresseeId == friendId) ||
             (f.RequesterId == friendId && f.AddresseeId == userId)), ct);

        if (!areFriends) return Forbid();

        var sessions = await db.WorkoutSessions
            .Where(w => w.UserId == friendId)
            .OrderByDescending(w => w.CompletedAtUtc)
            .Take(Math.Clamp(limit, 1, 100))
            .ToListAsync(ct);

        return Ok(sessions.Select(s => s.ToDto()).ToList());
    }

    private Guid GetUserId()
    {
        var raw = User.FindFirstValue("uid")
            ?? throw new InvalidOperationException("uid claim missing.");
        return Guid.Parse(raw);
    }
}

file static class FriendExtensions
{
    internal static UserResponse ToDto(this AppUser u) =>
        new(u.Id, u.DisplayName, u.AvatarUrl, u.CreatedAtUtc);

    internal static WorkoutResponse ToDto(this WorkoutSession s) => new(
        s.Id, s.ClientId, s.RoutineName, s.CompletedAtUtc,
        s.TotalDurationMs, s.SplitsJson, s.RoxZoneSplitsJson,
        s.AvgHeartRate, s.TotalCalories
    );
}
