namespace Hyrox.Api.Models;

public enum FriendshipStatus
{
    Pending,
    Accepted,
    Declined,
    Blocked,
}

public class Friendship
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid RequesterId { get; set; }
    public AppUser Requester { get; set; } = null!;

    public Guid AddresseeId { get; set; }
    public AppUser Addressee { get; set; } = null!;

    public FriendshipStatus Status { get; set; } = FriendshipStatus.Pending;

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
