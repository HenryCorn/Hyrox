using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Hyrox.Api.Models;
using Microsoft.IdentityModel.Tokens;

namespace Hyrox.Api.Services.Auth;

public sealed class JwtService(IConfiguration config) : IJwtService
{
    private const string UserIdClaim = "uid";

    private TokenValidationParameters BuildValidationParams() => new()
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = SigningKey(),
        ValidateIssuer = true,
        ValidIssuer = config["Jwt:Issuer"],
        ValidateAudience = true,
        ValidAudience = config["Jwt:Audience"],
        ValidateLifetime = true,
        ClockSkew = TimeSpan.FromMinutes(1),
    };

    private SymmetricSecurityKey SigningKey()
    {
        var key = config["Jwt:Key"]
            ?? throw new InvalidOperationException("Jwt:Key is not configured.");
        return new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
    }

    public string Issue(AppUser user)
    {
        var expiryMinutes = config.GetValue<int>("Jwt:ExpiryMinutes", 43_200); // 30 days default
        var claims = new[]
        {
            new Claim(UserIdClaim, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.DisplayName),
        };

        var token = new JwtSecurityToken(
            issuer: config["Jwt:Issuer"],
            audience: config["Jwt:Audience"],
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
            signingCredentials: new SigningCredentials(SigningKey(), SecurityAlgorithms.HmacSha256)
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public Guid? ValidateAndGetUserId(string token)
    {
        var handler = new JwtSecurityTokenHandler();
        try
        {
            var principal = handler.ValidateToken(token, BuildValidationParams(), out _);
            var raw = principal.FindFirstValue(UserIdClaim);
            return Guid.TryParse(raw, out var id) ? id : null;
        }
        catch
        {
            return null;
        }
    }
}
