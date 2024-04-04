using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DataContext.Migrations
{
    /// <inheritdoc />
    public partial class AddSignedUrlToTrack : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SignedUrl",
                table: "Tracks",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SignedUrl",
                table: "Tracks");
        }
    }
}
