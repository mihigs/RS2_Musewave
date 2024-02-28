using Playlist = Models.Entities.Playlist;

namespace Services.Interfaces
{
    public interface IPlaylistService
    {
        Task<IEnumerable<Playlist>> GetPlaylistsByNameAsync(string name, bool arePublic = true);
    }
}
