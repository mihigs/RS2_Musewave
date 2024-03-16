using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class PlaylistService : IPlaylistService
    {
        private readonly IPlaylistRepository _playlistRepository;

        public PlaylistService(IPlaylistRepository playlistRepository)
        {
            _playlistRepository = playlistRepository ?? throw new ArgumentNullException(nameof(playlistRepository));
        }

        public async Task<IEnumerable<Playlist>> GetPlaylistsByNameAsync(string name, bool arePublic = true)
        {
            return await _playlistRepository.GetPlaylistsByNameAsync(name, arePublic);
        }

        //public async Task<Playlist> GetPlaylistDetailsAsync(int id)
        //{
        //    return await _playlistRepository.GetPlaylistDetailsAsync(id);
        //}
        public async Task<Playlist> GetPlaylistDetailsAsync(int id)
        {
            return await _playlistRepository.GetPlaylistDetails(id);
        }


    }
}
