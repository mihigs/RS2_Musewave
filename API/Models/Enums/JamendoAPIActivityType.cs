using System.Data;
using System.Reflection;

namespace Models.Enums
{
    public enum JamendoAPIActivityType
    {
        SearchJamendoByTrackName = 1,
        GetTrackById = 2,
        GetJamendoTracksPerGenres = 3,
        GetPopularJamendoTracks = 4,
        GetJamendoArtistDetails = 5,
    }
}
