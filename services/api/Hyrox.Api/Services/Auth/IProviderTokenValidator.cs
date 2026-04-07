namespace Hyrox.Api.Services.Auth;

/// <summary>Result of validating an Apple or Google identity token.</summary>
public sealed record ProviderIdentity(string Subject, string? Email);

public interface IProviderTokenValidator
{
    /// <summary>
    /// Validates the provider-issued identity token and returns the stable user identity,
    /// or null if the token is invalid or expired.
    /// </summary>
    Task<ProviderIdentity?> ValidateAsync(string identityToken, CancellationToken ct = default);
}
