using DataContext.Repositories;
using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class SearchService : ISearchService
    {
        private readonly ISearchHistoryRepository _searchHistoryRepository;
        private readonly ITracksService _tracksService;
        private readonly IAlbumService _albumsService;
        private readonly IArtistService _artistsService;
        private readonly IPlaylistService _playlistsService;
        private readonly IJamendoService _jamendoService;


        public SearchService(
            ISearchHistoryRepository searchHistoryRepository,
            ITracksService tracksService,
            IAlbumService albumsService,
            IArtistService artistsService,
            IPlaylistService playlistsService,
            IJamendoService jamendoService
        )
        {
            _searchHistoryRepository = searchHistoryRepository;
            _tracksService = tracksService;
            _albumsService = albumsService;
            _artistsService = artistsService;
            _playlistsService = playlistsService;
            _jamendoService = jamendoService;
        }

        public async Task<SearchQueryResults> Query(string searchTerm, string userId)
        {
            List<Track> tracks = new List<Track>();
            List<Album> albums = new List<Album>();
            List<Artist> artists = new List<Artist>();
            List<Playlist> playlists = new List<Playlist>();
            List<Track> jamendoTracks = new List<Track>();

            // Consolidate search results from all services, while handling exceptions, making sure the search results are not lost
            try
            {
                tracks = (await _tracksService.GetTracksAsync(new TrackQuery { Name = searchTerm })).ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching tracks: {ex.Message}");
            }

            try
            {
                albums = (await _albumsService.GetAlbumsAsync(new AlbumQuery { Title = searchTerm })).ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching albums: {ex.Message}");
            }

            try
            {
                artists = (await _artistsService.GetArtistsAsync(new ArtistQuery { Name = searchTerm })).ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching artists: {ex.Message}");
            }

            try
            {
                playlists = (await _playlistsService.GetPlaylistsAsync(new PlaylistQuery { Name = searchTerm })).ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching playlists: {ex.Message}");
            }

            try
            {
                jamendoTracks = (await _jamendoService.GetJamendoTracksAsync(new JamendoTrackQuery { Name = searchTerm }, userId)).ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching Jamendo tracks: {ex.Message}");
            }

            var result = new SearchQueryResults
            {
                Tracks = tracks,
                Albums = albums,
                Artists = artists,
                Playlists = playlists,
                JamendoTracks = jamendoTracks
            };

            return result;
        }


        public async Task<IEnumerable<SearchHistory>> GetSearchHistorysAsync(string userId)
        {
            return await _searchHistoryRepository.GetSearchHistorysAsync(userId);
        }

        public async Task LogSearchRequestAsync(string searchTerm, string userId)
        {
            var searchHistory = new SearchHistory
            {
                SearchTerm = searchTerm,
                SearchDate = DateTime.UtcNow,
                UserId = userId
            };

            await _searchHistoryRepository.Add(searchHistory);
        }

        public async Task RemoveSearchHistoryAsync(int searchHistoryId)
        {
            var searchHistory = await _searchHistoryRepository.GetById(searchHistoryId);
            if (searchHistory is null)
            {
                return;
            }
            searchHistory.IsDeleted = true;
            await _searchHistoryRepository.Update(searchHistory);
        }
    }
}
