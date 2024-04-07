using System.Net;

namespace Models.DTOs
{
    public class CreateAndAddToPlaylistDto
    {
        public string PlaylistName { get; set; }
        public int TrackId { get; set; }
    }
}
