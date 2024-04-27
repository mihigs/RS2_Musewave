using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataContext.Migrations
{
    /// <inheritdoc />
    public partial class PlaylistTrack2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Tracks_Playlist_PlaylistId",
                table: "Tracks");

            migrationBuilder.DropIndex(
                name: "IX_Tracks_PlaylistId",
                table: "Tracks");

            migrationBuilder.DropColumn(
                name: "PlaylistId",
                table: "Tracks");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PlaylistId",
                table: "Tracks",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Tracks_PlaylistId",
                table: "Tracks",
                column: "PlaylistId");

            migrationBuilder.AddForeignKey(
                name: "FK_Tracks_Playlist_PlaylistId",
                table: "Tracks",
                column: "PlaylistId",
                principalTable: "Playlist",
                principalColumn: "Id");
        }
    }
}
