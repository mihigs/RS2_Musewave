using Models.Entities;

namespace Services.Interfaces
{
    public interface IExploreWeeklyGenerator
    {
        Task<Playlist> GenerateExploreWeeklyPlaylistForUser(string userId);
    }
}
