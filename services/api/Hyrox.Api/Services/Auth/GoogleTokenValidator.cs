using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;

namespace Hyrox.Api.Services.Auth;

/// <summary>
/// Validates Google Sign-In identity tokens by fetching Google's public JWKS and
/// verifying the RS256 signature, issuer, and audience (OAuth client ID).
/// </summary>
public sealed class GoogleTokenValidator : IProviderTokenValidator
{
    private const string GoogleDiscoveryUri = "https://accounts.google.com/.well-known/openid-configuration";

    private readonly string _clientId;
    private readonly ConfigurationManager<OpenIdConnectConfiguration> _configManager;

    public GoogleTokenValidator(IConfiguration config)
    {
        _clientId = config["GoogleSignIn:ClientId"]
            ?? throw new InvalidOperationException("GoogleSignIn:ClientId is not configured.");

        _configManager = new ConfigurationManager<OpenIdConnectConfiguration>(
            GoogleDiscoveryUri,
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
                ValidIssuers = ["https://accounts.google.com", "accounts.google.com"],
                ValidateAudience = true,
                ValidAudience = _clientId,
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
