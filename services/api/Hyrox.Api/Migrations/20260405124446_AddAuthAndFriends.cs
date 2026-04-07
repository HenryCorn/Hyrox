using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Hyrox.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddAuthAndFriends : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TotalTime",
                table: "WorkoutSessions");

            migrationBuilder.RenameColumn(
                name: "StartedAtUtc",
                table: "WorkoutSessions",
                newName: "CreatedAtUtc");

            migrationBuilder.RenameColumn(
                name: "Routine",
                table: "WorkoutSessions",
                newName: "SplitsJson");

            migrationBuilder.AlterColumn<Guid>(
                name: "UserId",
                table: "WorkoutSessions",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<int>(
                name: "AvgHeartRate",
                table: "WorkoutSessions",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ClientId",
                table: "WorkoutSessions",
                type: "character varying(128)",
                maxLength: 128,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedAtUtc",
                table: "WorkoutSessions",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "RoutineName",
                table: "WorkoutSessions",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "RoxZoneSplitsJson",
                table: "WorkoutSessions",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<double>(
                name: "TotalCalories",
                table: "WorkoutSessions",
                type: "double precision",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "TotalDurationMs",
                table: "WorkoutSessions",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DisplayName = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Email = table.Column<string>(type: "character varying(320)", maxLength: 320, nullable: true),
                    AppleSubject = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    GoogleSubject = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    AvatarUrl = table.Column<string>(type: "character varying(2048)", maxLength: 2048, nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Friendships",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    RequesterId = table.Column<Guid>(type: "uuid", nullable: false),
                    AddresseeId = table.Column<Guid>(type: "uuid", nullable: false),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Friendships", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Friendships_Users_AddresseeId",
                        column: x => x.AddresseeId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Friendships_Users_RequesterId",
                        column: x => x.RequesterId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_WorkoutSessions_UserId_ClientId",
                table: "WorkoutSessions",
                columns: new[] { "UserId", "ClientId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_WorkoutSessions_UserId_CompletedAtUtc",
                table: "WorkoutSessions",
                columns: new[] { "UserId", "CompletedAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_Friendships_AddresseeId",
                table: "Friendships",
                column: "AddresseeId");

            migrationBuilder.CreateIndex(
                name: "IX_Friendships_RequesterId_AddresseeId",
                table: "Friendships",
                columns: new[] { "RequesterId", "AddresseeId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_AppleSubject",
                table: "Users",
                column: "AppleSubject",
                unique: true,
                filter: "\"AppleSubject\" IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                filter: "\"Email\" IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Users_GoogleSubject",
                table: "Users",
                column: "GoogleSubject",
                unique: true,
                filter: "\"GoogleSubject\" IS NOT NULL");

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutSessions_Users_UserId",
                table: "WorkoutSessions",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutSessions_Users_UserId",
                table: "WorkoutSessions");

            migrationBuilder.DropTable(
                name: "Friendships");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropIndex(
                name: "IX_WorkoutSessions_UserId_ClientId",
                table: "WorkoutSessions");

            migrationBuilder.DropIndex(
                name: "IX_WorkoutSessions_UserId_CompletedAtUtc",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "AvgHeartRate",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "ClientId",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "CompletedAtUtc",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "RoutineName",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "RoxZoneSplitsJson",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "TotalCalories",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "TotalDurationMs",
                table: "WorkoutSessions");

            migrationBuilder.RenameColumn(
                name: "SplitsJson",
                table: "WorkoutSessions",
                newName: "Routine");

            migrationBuilder.RenameColumn(
                name: "CreatedAtUtc",
                table: "WorkoutSessions",
                newName: "StartedAtUtc");

            migrationBuilder.AlterColumn<string>(
                name: "UserId",
                table: "WorkoutSessions",
                type: "text",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddColumn<TimeSpan>(
                name: "TotalTime",
                table: "WorkoutSessions",
                type: "interval",
                nullable: false,
                defaultValue: new TimeSpan(0, 0, 0, 0, 0));
        }
    }
}
