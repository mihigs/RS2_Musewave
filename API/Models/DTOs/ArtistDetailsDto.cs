using Models.Entities;

namespace Models.DTOs
{
    public class ArtistDetailsDto
    {
        public Artist Artist { get; set; }
        public List<Track> Tracks { get; set; }
    }
}
