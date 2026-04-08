using Hyrox.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Hyrox.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<AppUser> Users => Set<AppUser>();
    public DbSet<WorkoutSession> WorkoutSessions => Set<WorkoutSession>();
    public DbSet<Friendship> Friendships => Set<Friendship>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // ── AppUser ────────────────────────────────────────────────────────
        modelBuilder.Entity<AppUser>(e =>
        {
            e.HasKey(u => u.Id);
            e.Property(u => u.DisplayName).HasMaxLength(100).IsRequired();
            e.Property(u => u.Email).HasMaxLength(320);
            e.Property(u => u.AppleSubject).HasMaxLength(256);
            e.Property(u => u.GoogleSubject).HasMaxLength(256);
            e.Property(u => u.AvatarUrl).HasMaxLength(2048);

            // Unique indexes for provider subjects — used for lookup on sign-in
            e.HasIndex(u => u.AppleSubject).IsUnique().HasFilter("\"AppleSubject\" IS NOT NULL");
            e.HasIndex(u => u.GoogleSubject).IsUnique().HasFilter("\"GoogleSubject\" IS NOT NULL");
            e.HasIndex(u => u.Email).HasFilter("\"Email\" IS NOT NULL");
        });

        // ── WorkoutSession ─────────────────────────────────────────────────
        modelBuilder.Entity<WorkoutSession>(e =>
        {
            e.HasKey(w => w.Id);
            e.Property(w => w.RoutineName).HasMaxLength(200).IsRequired();
            e.Property(w => w.ClientId).HasMaxLength(128).IsRequired();

            // Idempotency: one ClientId per user
            e.HasIndex(w => new { w.UserId, w.ClientId }).IsUnique();

            e.HasOne(w => w.User)
             .WithMany(u => u.Workouts)
             .HasForeignKey(w => w.UserId)
             .OnDelete(DeleteBehavior.Cascade);

            e.HasIndex(w => new { w.UserId, w.CompletedAtUtc });
        });

        // ── Friendship ─────────────────────────────────────────────────────
        modelBuilder.Entity<Friendship>(e =>
        {
            e.HasKey(f => f.Id);
            e.Property(f => f.Status).HasConversion<string>().HasMaxLength(20);

            // Prevent duplicate friendship rows in either direction
            e.HasIndex(f => new { f.RequesterId, f.AddresseeId }).IsUnique();

            e.HasOne(f => f.Requester)
             .WithMany(u => u.SentRequests)
             .HasForeignKey(f => f.RequesterId)
             .OnDelete(DeleteBehavior.Restrict);

            e.HasOne(f => f.Addressee)
             .WithMany(u => u.ReceivedRequests)
             .HasForeignKey(f => f.AddresseeId)
             .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
