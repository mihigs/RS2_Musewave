using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataContext.Migrations
{
    /// <inheritdoc />
    public partial class AddReporting : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "JoinDate",
                table: "AspNetUsers",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.CreateTable(
                name: "Reports",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NewMusewaveTrackCount = table.Column<int>(type: "int", nullable: false),
                    NewJamendoTrackCount = table.Column<int>(type: "int", nullable: false),
                    NewUserCount = table.Column<int>(type: "int", nullable: false),
                    NewArtistCount = table.Column<int>(type: "int", nullable: false),
                    DailyLoginCount = table.Column<int>(type: "int", nullable: false),
                    MonthlyJamendoApiActivity = table.Column<int>(type: "int", nullable: false),
                    MonthlyTimeListened = table.Column<int>(type: "int", nullable: false),
                    MonthlyDonationsAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    MonthlyDonationsCount = table.Column<int>(type: "int", nullable: false),
                    ReportMonth = table.Column<int>(type: "int", nullable: false),
                    ReportYear = table.Column<int>(type: "int", nullable: false),
                    ReportDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reports", x => x.Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Reports");

            migrationBuilder.DropColumn(
                name: "JoinDate",
                table: "AspNetUsers");
        }
    }
}
