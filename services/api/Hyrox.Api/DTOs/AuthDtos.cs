namespace Hyrox.Api.DTOs;

public record SignInRequest(
    /// <summary>"apple" or "google"</summary>
    string Provider,
    /// <summary>Identity token from Apple/Google SDK.</summary>
    string IdentityToken,
    /// <summary>Optional display name sent on first sign-in.</summary>
    string? DisplayName
);

public record SignInResponse(
    string AccessToken,
    UserResponse User
);
