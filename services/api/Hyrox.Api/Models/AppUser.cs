namespace Hyrox.Api.Models;

public class AppUser
{
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>Display name chosen by the user.</summary>
    public string DisplayName { get; set; } = "Athlete";

    public string? Email { get; set; }

    /// <summary>Stable identifier from Apple's identity token ("sub" claim).</summary>
    public string? AppleSubject { get; set; }

    /// <summary>Stable identifier from Google's identity token ("sub" claim).</summary>
    public string? GoogleSubject { get; set; }

    public string? AvatarUrl { get; set; }

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;

    // Navigation
    public ICollection<WorkoutSession> Workouts { get; set; } = [];
    public ICollection<Friendship> SentRequests { get; set; } = [];
    public ICollection<Friendship> ReceivedRequests { get; set; } = [];
}
