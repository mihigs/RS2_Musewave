using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class ExploreWeeklyPlaylistGenerator : BackgroundService
    {
        private readonly IRedisService _redisService;
        private readonly IServiceScopeFactory _serviceScopeFactory;

        public ExploreWeeklyPlaylistGenerator(IRedisService redisService, IServiceScopeFactory serviceScopeFactory)
        {
            _redisService = redisService;
            _serviceScopeFactory = serviceScopeFactory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(TimeSpan.FromDays(1), stoppingToken); // Every day

                Console.WriteLine("Explore weekly generator is running.");

                await GenerateExploreWeeklyPlaylists();

                Console.WriteLine("Explore weekly generator has finished!");
            }
        }

        // Assuming `GetGenreIdsForTrack` and similar helper methods are correctly defined elsewhere

        private async Task GenerateExploreWeeklyPlaylists()
        {
            var similarityMatrix = await _redisService.GetSimilarityMatrixAsync(); // Ensure this returns the expected structure
            if (similarityMatrix == null)
            {
                Console.WriteLine("Similarity matrix not found in Redis. Skipping generation of Explore Weekly playlists.");
                return;
            }

            using (var scope = _serviceScopeFactory.CreateScope())
            {
                var playlistRepository = scope.ServiceProvider.GetRequiredService<IPlaylistRepository>();
                var userRepository = scope.ServiceProvider.GetRequiredService<IUserRepository>();
                var trackRepository = scope.ServiceProvider.GetRequiredService<ITrackRepository>();
                var likeRepository = scope.ServiceProvider.GetRequiredService<ILikeRepository>();
                var trackGenreRepository = scope.ServiceProvider.GetRequiredService<ITrackGenreRepository>();

                // 1. Fetch all users
                var users = await userRepository.GetAll();

                foreach (var user in users)
                {
                    // 2. For each user, get their liked tracks
                    var likedTracks = await likeRepository.GetByUserAsync(user.Id);

                    // 3. Get the genres of each of those tracks
                    var userLikedGenreIds = new HashSet<string>(); // Use HashSet to avoid duplicates
                    foreach (var track in likedTracks)
                    {
                        var genresForTrack = await trackGenreRepository.GetGenresByTrackId(track.Id);
                        foreach (var genre in genresForTrack)
                        {
                            userLikedGenreIds.Add(genre.Name); // Assuming genre has a Name property
                        }
                    }
                    var userLikedGenreIdsInt = userLikedGenreIds.Select(int.Parse).ToList(); // convert to List<int>

                    // 4. Use the similarity matrix to find tracks with similar genres
                    var similarTracks = new HashSet<Track>(); // Using HashSet to avoid duplicate tracks
                    var similarGenres = new HashSet<int>(); // To store IDs of genres similar to the user's liked genres

                    foreach (var userGenreId in userLikedGenreIdsInt)
                    {
                        // Find similar genres based on the similarity matrix
                        foreach (var entry in similarityMatrix)
                        {
                            var genres = entry.Key.Split('-').Select(int.Parse).ToArray();
                            if (genres.Contains(userGenreId) && entry.Value > 0.5) // Assuming a threshold for similarity
                            {
                                similarGenres.UnionWith(genres);
                            }
                        }
                    }

                    // 5. Remove the genres already liked by the user to avoid recommending the same tracks
                    similarGenres.ExceptWith(userLikedGenreIdsInt);

                    foreach (var genreId in similarGenres)
                    {
                        // This method needs to be implemented to fetch tracks by genre ID
                        var tracksInGenre = await trackRepository.GetTracksByGenreAsync(genreId);
                        foreach (var track in tracksInGenre)
                        {
                            if (!likedTracks.Any(t => t.Id == track.Id))
                            {
                                similarTracks.Add(track);
                            }
                        }
                    }

                    // 6. Create a new playlist called "Explore Weekly" for each user and add the similar tracks to this playlist
                    // Convert HashSet to List or appropriate collection as needed
                    var exploreWeeklyPlaylist = new Playlist
                    {
                        Name = "Explore Weekly",
                        UserId = user.Id,
                        Tracks = similarTracks.ToList() // Assuming your Playlist entity can take a List<Track>
                    };

                    await playlistRepository.Add(exploreWeeklyPlaylist);
                    Console.WriteLine($"Explore Weekly playlist created for user {user.Id}.");
                }
            }
        }


    }

}
