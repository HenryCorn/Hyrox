using System.Security.Claims;
using Hyrox.Api.Data;
using Hyrox.Api.DTOs;
using Hyrox.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Hyrox.Api.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public sealed class UsersController(AppDbContext db) : ControllerBase
{
    [HttpGet("me")]
    [ProducesResponseType<UserResponse>(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMe(CancellationToken ct)
    {
        var userId = GetUserId();
        var user = await db.Users.FindAsync([userId], ct);
        return user is null ? NotFound() : Ok(user.ToDto());
    }

    [HttpPatch("me")]
    [ProducesResponseType<UserResponse>(StatusCodes.Status200OK)]
    public async Task<IActionResult> UpdateMe([FromBody] UpdateUserRequest request, CancellationToken ct)
    {
        var userId = GetUserId();
        var user = await db.Users.FindAsync([userId], ct);
        if (user is null) return NotFound();

        var changed = false;

        if (request.DisplayName is { Length: > 0 } name && name != user.DisplayName)
        {
            user.DisplayName = name.Trim()[..Math.Min(name.Trim().Length, 100)];
            changed = true;
        }
        if (request.AvatarUrl != user.AvatarUrl)
        {
            user.AvatarUrl = request.AvatarUrl;
            changed = true;
        }

        if (changed)
        {
            user.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
        }

        return Ok(user.ToDto());
    }

    [HttpGet("search")]
    [ProducesResponseType<List<UserSearchResult>>(StatusCodes.Status200OK)]
    public async Task<IActionResult> Search([FromQuery] string q, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(q) || q.Length < 2)
            return BadRequest(new { error = "Query must be at least 2 characters." });

        var userId = GetUserId();
        var term = q.Trim().ToLower();

        var users = await db.Users
            .Where(u => u.Id != userId && u.DisplayName.ToLower().Contains(term))
            .Take(20)
            .ToListAsync(ct);

        // Look up existing friendship statuses in one query
        var userIds = users.Select(u => u.Id).ToList();
        var friendships = await db.Friendships
            .Where(f =>
                (f.RequesterId == userId && userIds.Contains(f.AddresseeId)) ||
                (f.AddresseeId == userId && userIds.Contains(f.RequesterId)))
            .ToListAsync(ct);

        var results = users.Select(u =>
        {
            var fs = friendships.FirstOrDefault(f =>
                f.RequesterId == u.Id || f.AddresseeId == u.Id);
            return new UserSearchResult(u.Id, u.DisplayName, u.AvatarUrl, fs?.Status.ToString());
        }).ToList();

        return Ok(results);
    }

    private Guid GetUserId()
    {
        var raw = User.FindFirstValue("uid")
            ?? throw new InvalidOperationException("uid claim missing.");
        return Guid.Parse(raw);
    }
}

file static class UserExtensions
{
    internal static UserResponse ToDto(this AppUser u) =>
        new(u.Id, u.DisplayName, u.AvatarUrl, u.CreatedAtUtc);
}
