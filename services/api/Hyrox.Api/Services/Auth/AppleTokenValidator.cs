using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;

namespace Hyrox.Api.Services.Auth;

/// <summary>
/// Validates Apple Sign-In identity tokens by fetching Apple's public JWKS and
/// verifying the RS256 signature, issuer, and audience (app bundle ID).
/// </summary>
public sealed class AppleTokenValidator : IProviderTokenValidator
{
    private const string AppleIssuer = "https://appleid.apple.com";
    private const string AppleJwksUri = "https://appleid.apple.com/auth/keys";

    private readonly string _bundleId;
    private readonly ConfigurationManager<OpenIdConnectConfiguration> _configManager;

    public AppleTokenValidator(IConfiguration config)
    {
        _bundleId = config["AppleSignIn:AppBundleId"]
            ?? throw new InvalidOperationException("AppleSignIn:AppBundleId is not configured.");

        _configManager = new ConfigurationManager<OpenIdConnectConfiguration>(
            AppleJwksUri,
            new OpenIdConnectConfigurationRetriever(),
            new HttpDocumentRetriever { RequireHttps = true }
        );
    }

    public async Task<ProviderIdentity?> ValidateAsync(string identityToken, CancellationToken ct = default)
    {
        try
        {
            var config = await _configManager.GetConfigurationAsync(ct);

            var validationParams = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKeys = config.SigningKeys,
                ValidateIssuer = true,
                ValidIssuer = AppleIssuer,
                ValidateAudience = true,
                ValidAudience = _bundleId,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromMinutes(5),
            };

            var handler = new JwtSecurityTokenHandler();
            var principal = handler.ValidateToken(identityToken, validationParams, out _);

            var sub = principal.FindFirst("sub")?.Value;
            var email = principal.FindFirst("email")?.Value;

            return sub is not null ? new ProviderIdentity(sub, email) : null;
        }
        catch (Exception)
        {
            return null;
        }
    }
}
