namespace Hyrox.Api.DTOs;

public record UserResponse(
    Guid Id,
    string DisplayName,
    string? AvatarUrl,
    DateTime CreatedAtUtc
);

public record UpdateUserRequest(
    string? DisplayName,
    string? AvatarUrl
);

public record UserSearchResult(
    Guid Id,
    string DisplayName,
    string? AvatarUrl,
    /// <summary>Friendship status relative to the requesting user, or null if no relationship.</summary>
    string? FriendshipStatus
);
