namespace Hyrox.Api.DTOs;

public record FriendResponse(
    Guid FriendshipId,
    UserResponse Friend,
    DateTime FriendsSince
);

public record FriendRequestResponse(
    Guid FriendshipId,
    UserResponse From,
    DateTime SentAt
);

public record SendFriendRequestRequest(Guid AddresseeId);
