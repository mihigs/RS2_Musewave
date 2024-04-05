using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Models.Entities;
using Services.Interfaces;
using System.Text.Json;

namespace Services.Implementations
{
    public class GenreSimilarityTracker : BackgroundService
    {
        private readonly IRedisService _redisService;
        private readonly IServiceScopeFactory _serviceScopeFactory;

        public GenreSimilarityTracker(IRedisService redisService, IServiceScopeFactory serviceScopeFactory)
        {
            _redisService = redisService;
            _serviceScopeFactory = serviceScopeFactory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                Console.WriteLine("Genre similarity tracker is running.");

                await CalculateAndStoreGenreSimilarities();

                Console.WriteLine("Genre similarity tracker has finished!");

                await Task.Delay(TimeSpan.FromDays(1), stoppingToken); // Every day
            }
        }

        public async Task CalculateAndStoreGenreSimilarities()
        {
            using (var scope = _serviceScopeFactory.CreateScope())
            {
                // Step 1: Get the TrackGenre repository
                var trackGenreRepository = scope.ServiceProvider.GetRequiredService<ITrackGenreRepository>();

                // Step 2: Fetch TrackGenres from the database
                var trackGenres = await trackGenreRepository.GetAll();

                // Step 3: Calculate Co-occurrence matrix
                var coOccurrenceMatrix = CalculateCoOccurrenceMatrix(trackGenres.ToList());

                // Step 4: Calculate similarities based on the co-occurrence matrix
                var similarityMatrix = CalculateSimilarityMatrix(coOccurrenceMatrix, trackGenres.ToList());

                // Step 5: Store the similarity matrix in Redis
                await _redisService.StoreSimilarityMatrixAsync(similarityMatrix);
            }
        }


        public Dictionary<string, int> CalculateCoOccurrenceMatrix(List<TrackGenre> trackGenres)
        {
            // Initialize an empty dictionary to store co-occurrence counts for each genre pair.
            var coOccurrenceMatrix = new Dictionary<string, int>();

            // Group track genres by track ID, effectively grouping genres by the track they belong to.
            foreach (var trackGroup in trackGenres.GroupBy(tg => tg.TrackId))
            {
                // Extract and distinctively list the genre IDs associated with the current track.
                var genres = trackGroup.Select(tg => tg.GenreId).Distinct().ToList();

                // Compare every possible pair of genres within this track.
                foreach (var genre1 in genres)
                {
                    foreach (var genre2 in genres)
                    {
                        // Ensure we're not comparing a genre with itself.
                        if (genre1 != genre2)
                        {
                            // Create a string key representing the genre pair, ensuring the lower ID
                            // comes first to maintain consistency (genre pairs are unordered).
                            var key = $"{Math.Min(genre1, genre2)}-{Math.Max(genre1, genre2)}";

                            // If this genre pair has already been encountered, increment their
                            // co-occurrence count. Otherwise, initialize it to 1.
                            if (coOccurrenceMatrix.ContainsKey(key))
                                coOccurrenceMatrix[key]++;
                            else
                                coOccurrenceMatrix[key] = 1;
                        }
                    }
                }
            }

            // Return the completed co-occurrence matrix.
            return coOccurrenceMatrix;
        }


        public Dictionary<string, double> CalculateSimilarityMatrix(Dictionary<string, int> coOccurrenceMatrix, List<TrackGenre> trackGenres)
        {
            // Initialize an empty dictionary for the similarity scores between genre pairs.
            var similarityMatrix = new Dictionary<string, double>();

            // Calculate the total number of tracks associated with each genre.
            var genreCounts = trackGenres.GroupBy(tg => tg.GenreId)
                                         .ToDictionary(group => group.Key, group => group.Count());

            // Iterate through each genre pair in the co-occurrence matrix.
            foreach (var key in coOccurrenceMatrix.Keys)
            {
                // Convert the string key back into the two genre IDs it represents.
                var genres = key.Split('-').Select(int.Parse).ToArray();
                var genre1 = genres[0];
                var genre2 = genres[1];

                // The co-occurrence count for the genre pair.
                var intersection = coOccurrenceMatrix[key];

                // Calculate the "union" of the two genres, which is the total count for each,
                // minus the intersection to avoid double counting.
                var union = genreCounts[genre1] + genreCounts[genre2] - intersection;

                // Calculate the similarity score (Jaccard index): intersection over union.
                // This measures how similar the two genres are based on their co-occurrences across tracks.
                var similarity = union == 0 ? 0 : (double)intersection / union;

                // Store the similarity score with the genre pair as the key.
                similarityMatrix[key] = similarity;
            }

            return similarityMatrix;
        }


    }

}
