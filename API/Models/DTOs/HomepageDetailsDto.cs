using Models.Entities;
using System.Net;

namespace Models.DTOs
{
    public class HomepageDetailsDto
    {
        public int ExploreWeeklyPlaylistId { get; set; }
        public List<Track> PopularJamendoTracks { get; set; }
    }
}
