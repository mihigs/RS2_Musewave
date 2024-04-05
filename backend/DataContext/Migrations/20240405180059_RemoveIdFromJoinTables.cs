using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataContext.Migrations
{
    /// <inheritdoc />
    public partial class RemoveIdFromJoinTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Id",
                table: "TrackGenres");

            migrationBuilder.DropColumn(
                name: "Id",
                table: "PlaylistTrack");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Id",
                table: "TrackGenres",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Id",
                table: "PlaylistTrack",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }
    }
}
