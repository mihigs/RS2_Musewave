using Models.Entities;
using System.Net;

namespace Models.DTOs
{
    public class ArtistDetailsDto
    {
        public Artist Artist { get; set; }
        public List<Track> Tracks { get; set; }
    }
}
