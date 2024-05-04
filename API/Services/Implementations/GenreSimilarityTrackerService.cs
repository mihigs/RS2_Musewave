using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class GenreSimilarityTrackerService : IGenreSimilarityTrackerService
    {
        private readonly IRedisService _redisService;
        private readonly ITrackGenreRepository _trackGenreRepository;
        private readonly IGenreRepository _genreRepository;

        public GenreSimilarityTrackerService(IRedisService redisService, ITrackGenreRepository trackGenreRepository, IGenreRepository genreRepository)
        {
            _redisService = redisService;
            _trackGenreRepository = trackGenreRepository;
            _genreRepository = genreRepository;
        }

        public async Task<SimilarityMatrixDto> CalculateAndStoreGenreSimilarities()
        {
            try
            {
                Console.WriteLine("Genre similarity tracker is running.");

                // Step 1: Fetch TrackGenres from the database
                var trackGenres = await _trackGenreRepository.GetAll();

                // Step 2: Calculate Co-occurrence matrix
                var coOccurrenceMatrix = CalculateCoOccurrenceMatrix(trackGenres.ToList());

                // Step 3: Calculate similarities based on the co-occurrence matrix
                var similarityMatrix = CalculateSimilarityMatrix(coOccurrenceMatrix, trackGenres.ToList());

                // Step 4: Store the similarity matrix in Redis
                await _redisService.StoreSimilarityMatrixAsync(similarityMatrix);

                // Step 5: Create and return the SimilarityMatrixDto
                Console.WriteLine("Genre similarity tracker has finished!");
                return await CreateSimilarityMatrixDto(similarityMatrix);

            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in GenreSimilarityTracker: {ex.Message}");
                return null;
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

        public async Task<Dictionary<string, double>?> GetSimilarityMatrixAsync()
        {
            try
            {
                return await _redisService.GetSimilarityMatrixAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in GetSimilarityMatrixAsync: {ex.Message}");
                return null;
            }
        }

        public async Task<SimilarityMatrixDto> GetSimilarityMatrixDtoAsync()
        {
            var similarityMatrixRaw = await GetSimilarityMatrixAsync();
            if (similarityMatrixRaw == null)
            {
                return new SimilarityMatrixDto();
            }

            return await CreateSimilarityMatrixDto(similarityMatrixRaw);
        }

        private async Task<SimilarityMatrixDto> CreateSimilarityMatrixDto(Dictionary<string, double> rawData)
        {
            HashSet<int> genreIds = new HashSet<int>();

            // Extract genre IDs
            foreach (var key in rawData.Keys)
            {
                var ids = key.Split('-').Select(int.Parse).ToList();
                genreIds.UnionWith(ids);
            }

            // Fetch Genre objects
            // convert HashSet<int> to List<int>
            var genres = await _genreRepository.GetGenresByIdsAsync(genreIds.ToList());

            // Map genres to a sorted list of Genre objects
            var sortedGenres = genres.OrderBy(g => g.Id).ToList();

            // Create the similarity matrix
            var matrix = new List<List<double>>();
            int size = sortedGenres.Count;
            for (int i = 0; i < size; i++)
            {
                matrix.Add(new List<double>(Enumerable.Repeat(0.0, size)));
            }

            // Populate the matrix
            foreach (var item in rawData)
            {
                var ids = item.Key.Split('-').Select(int.Parse).ToList();
                int index1 = sortedGenres.FindIndex(g => g.Id == ids[0]);
                int index2 = sortedGenres.FindIndex(g => g.Id == ids[1]);
                matrix[index1][index2] = item.Value;
                matrix[index2][index1] = item.Value;
            }

            // Create and return the DTO
            return new SimilarityMatrixDto
            {
                Genres = sortedGenres,
                SimilarityScores = matrix
            };
        }

    }
}
