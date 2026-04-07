using Hyrox.Api.Data;
using Hyrox.Api.DTOs;
using Hyrox.Api.Models;
using Hyrox.Api.Services.Auth;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Hyrox.Api.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController(
    AppDbContext db,
    IJwtService jwt,
    AppleTokenValidator appleValidator,
    GoogleTokenValidator googleValidator,
    ILogger<AuthController> logger) : ControllerBase
{
    [HttpPost("signin")]
    [ProducesResponseType<SignInResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> SignIn([FromBody] SignInRequest request, CancellationToken ct)
    {
        IProviderTokenValidator validator = request.Provider.ToLower() switch
        {
            "apple" => appleValidator,
            "google" => googleValidator,
            _ => throw new ArgumentOutOfRangeException(nameof(request.Provider),
                    "Provider must be 'apple' or 'google'.")
        };

        var identity = await validator.ValidateAsync(request.IdentityToken, ct);
        if (identity is null)
        {
            logger.LogWarning("Invalid {Provider} identity token", request.Provider);
            return Unauthorized(new { error = "Invalid or expired identity token." });
        }

        // Find or create the user
        var user = request.Provider.ToLower() == "apple"
            ? await db.Users.FirstOrDefaultAsync(u => u.AppleSubject == identity.Subject, ct)
            : await db.Users.FirstOrDefaultAsync(u => u.GoogleSubject == identity.Subject, ct);

        if (user is null)
        {
            user = new AppUser
            {
                DisplayName = request.DisplayName?.Trim().Take(100).AsString() ?? "Athlete",
                Email = identity.Email,
            };

            if (request.Provider.ToLower() == "apple") user.AppleSubject = identity.Subject;
            else user.GoogleSubject = identity.Subject;

            db.Users.Add(user);
            await db.SaveChangesAsync(ct);

            logger.LogInformation("New user created {UserId} via {Provider}", user.Id, request.Provider);
        }
        else
        {
            // Keep email in sync in case it was previously hidden
            if (identity.Email is not null && user.Email != identity.Email)
            {
                user.Email = identity.Email;
                user.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }
        }

        var token = jwt.Issue(user);
        return Ok(new SignInResponse(token, user.ToDto()));
    }
}

file static class StringExtensions
{
    internal static IEnumerable<char> Take(this string s, int count) => s.AsEnumerable().Take(count);
    internal static string AsString(this IEnumerable<char> chars) => new(chars.ToArray());
    internal static UserResponse ToDto(this AppUser u) =>
        new(u.Id, u.DisplayName, u.AvatarUrl, u.CreatedAtUtc);
}
