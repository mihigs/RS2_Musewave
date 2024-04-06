using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Models.Entities;
using Services.Interfaces;
using System;

namespace Services.Implementations.BackgroundServices
{
    public class ExploreWeeklyPlaylistGenerator : BackgroundService
    {
        private readonly IRedisService _redisService;
        private readonly IServiceScopeFactory _serviceScopeFactory;
        private readonly IServiceProvider _serviceProvider;

        public ExploreWeeklyPlaylistGenerator(IRedisService redisService, IServiceScopeFactory serviceScopeFactory, IServiceProvider serviceProvider)
        {
            _redisService = redisService;
            _serviceScopeFactory = serviceScopeFactory;
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                while (!stoppingToken.IsCancellationRequested)
                {
                    _serviceProvider.GetRequiredService<ServiceRunControl>().WaitGenreSimilarityTrackerDone(stoppingToken);  // Wait for GenreSimilarityTracker to finish

                    Console.WriteLine("Explore weekly generator is running.");
                    await GenerateExploreWeeklyPlaylists();
                    Console.WriteLine("Explore weekly generator has finished!");

                    await Task.Delay(TimeSpan.FromDays(1), stoppingToken); // Every day
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in ExploreWeeklyPlaylistGenerator: {ex.Message}");
            }
        }


        private async Task GenerateExploreWeeklyPlaylists()
        {
            var similarityMatrix = await _redisService.GetSimilarityMatrixAsync();
            if (similarityMatrix.IsNullOrEmpty())
            {
                Console.WriteLine("Similarity matrix not found in Redis. Skipping generation of Explore Weekly playlists.");
                return;
            }

            using (var scope = _serviceScopeFactory.CreateScope())
            {
                var playlistRepository = scope.ServiceProvider.GetRequiredService<IPlaylistRepository>();
                var playlistTrackRepository = scope.ServiceProvider.GetRequiredService<IPlaylistTrackRepository>();
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
                    var userLikedGenreIds = new HashSet<int>(); // Using HashSet to avoid duplicates
                    foreach (var track in likedTracks)
                    {
                        var genresForTrack = await trackGenreRepository.GetGenresByTrackId(track.Id);
                        foreach (var genre in genresForTrack)
                        {
                            userLikedGenreIds.Add(genre.Id);
                        }
                    }

                    // 4. Use the similarity matrix to find tracks with similar genres
                    var similarTracks = new HashSet<Track>(); // Using HashSet to avoid duplicate tracks
                    var similarGenres = new HashSet<int>(); // To store IDs of genres similar to the user's liked genres

                    foreach (var userGenreId in userLikedGenreIds)
                    {
                        // Find similar genres based on the similarity matrix
                        foreach (var entry in similarityMatrix)
                        {
                            var genres = entry.Key.Split('-').Select(int.Parse).ToArray();
                            if (genres.Contains(userGenreId) && entry.Value > 0.4) // Threshold for similarity
                            {
                                similarGenres.UnionWith(genres);
                            }
                        }
                    }

                    // 5. Remove the genres already liked by the user to avoid recommending the same tracks
                    similarGenres.ExceptWith(userLikedGenreIds);

                    foreach (var genreId in similarGenres)
                    {
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
                    var exploreWeeklyPlaylist = new Playlist
                    {
                        Name = "Explore Weekly",
                        UserId = user.Id,
                        //Tracks = similarTracks.ToList(),
                        IsPublic = false,
                        IsExploreWeekly = true
                    };
                    foreach (var track in similarTracks)
                    {
                        exploreWeeklyPlaylist.Tracks.Add(new PlaylistTrack { Track = track });
                    }

                    await playlistRepository.Add(exploreWeeklyPlaylist);
                    await playlistTrackRepository.AddTracksToPlaylist(exploreWeeklyPlaylist.Id, similarTracks);
                    Console.WriteLine($"Explore Weekly playlist created for user {user.Id}.");
                }
            }
        }


    }

}
