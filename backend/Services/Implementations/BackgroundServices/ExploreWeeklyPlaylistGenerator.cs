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
                    if (likedTracks.IsNullOrEmpty())
                    {
                        continue;
                    }

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
                    if (userLikedGenreIds.IsNullOrEmpty())
                    {
                        continue;
                    }

                    // 4. Use the similarity matrix to find tracks with similar genres
                    var similarGenres = new Dictionary<int, double>(); // To store IDs of genres similar to the user's liked genres, and the similarity score

                    foreach (var userGenreId in userLikedGenreIds)
                    {
                        // Find similar genres based on the similarity matrix
                        foreach (var entry in similarityMatrix)
                        {
                            var genres = entry.Key.Split('-').Select(int.Parse).ToArray();
                            if ((genres.Contains(userGenreId) && entry.Value > 0.5)) // Threshold for similarity
                            {
                                foreach (var genreId in genres)
                                {
                                    // Check if the genre is not already liked by the user
                                    if (!userLikedGenreIds.Contains(genreId))
                                    {
                                        // Update or add the genre with its similarity score
                                        if (similarGenres.ContainsKey(genreId))
                                        {
                                            // Update the score if the new score is higher
                                            if (similarGenres[genreId] < entry.Value)
                                            {
                                                similarGenres[genreId] = entry.Value;
                                            }
                                        }
                                        else
                                        {
                                            similarGenres.Add(genreId, entry.Value);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (similarGenres.IsNullOrEmpty())
                    {
                        continue;
                    }

                    // 5. Filter 30 of the most similar genres
                    var topSimilarGenres = similarGenres.OrderByDescending(entry => entry.Value)
                                    .Take(30)
                                    .ToDictionary(pair => pair.Key, pair => pair.Value);
                    similarGenres = topSimilarGenres;

                    // 6. Remove the genres already liked by the user to avoid recommending the same tracks
                    var similarTracks = new HashSet<Track>(); // Using HashSet to avoid duplicate tracks

                    // Helper function to add tracks
                    async Task AddTracksPerGenre(IEnumerable<int> genreIds, int tracksToAddPerGenre)
                    {
                        foreach (var genreId in genreIds)
                        {
                            var tracksInGenre = await trackRepository.GetTracksByGenreAsync(genreId);
                            var addedTracks = 0;

                            foreach (var track in tracksInGenre)
                            {
                                if (!likedTracks.Any(t => t.Id == track.Id) && !similarTracks.Any(t => t.Id == track.Id))
                                {
                                    similarTracks.Add(track);
                                    addedTracks++;
                                    if (addedTracks >= tracksToAddPerGenre) break; // Stop after adding the specified number of tracks per genre
                                }
                            }
                        }
                    }

                    // First pass: Add one track per genre
                    await AddTracksPerGenre(similarGenres.Keys, 2);

                    // Subsequent passes: Add more tracks per genre if needed
                    while (similarTracks.Count < 30)
                    {
                        var previousCount = similarTracks.Count;
                        await AddTracksPerGenre(similarGenres.Keys, 1); // Try adding one more track per genre
                        if (similarTracks.Count == previousCount) break; // Break if no new tracks were added
                    }

                    //foreach (var genreId in similarGenres.Keys)
                    //{
                    //    var tracksInGenre = await trackRepository.GetTracksByGenreAsync(genreId);
                    //    foreach (var track in tracksInGenre)
                    //    {
                    //        if (!likedTracks.Any(t => t.Id == track.Id))
                    //        {
                    //            similarTracks.Add(track);
                    //        }
                    //    }
                    //}


                    // 7. Create a new playlist called "Explore Weekly" for each user and add the similar tracks to this playlist
                    var exploreWeeklyPlaylist = new Playlist
                    {
                        Name = "Explore Weekly",
                        UserId = user.Id,
                        IsPublic = false,
                        IsExploreWeekly = true
                    };
                    foreach (var track in similarTracks)
                    {
                        exploreWeeklyPlaylist.Tracks.Add(new PlaylistTrack { Track = track });
                    }

                    await playlistRepository.Add(exploreWeeklyPlaylist);
                    //await playlistTrackRepository.AddTracksToPlaylist(exploreWeeklyPlaylist.Id, similarTracks);
                    Console.WriteLine($"Explore Weekly playlist created for user {user.Id}.");
                }
            }
        }


    }

}
