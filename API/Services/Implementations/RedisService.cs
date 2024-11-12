using Services.Interfaces;
using StackExchange.Redis;
using System.Text.Json;

namespace Services.Implementations
{
    public class RedisService : IRedisService
    {
        private readonly IConnectionMultiplexer _redisConnection;

        public RedisService(IConnectionMultiplexer redisConnection)
        {
            _redisConnection = redisConnection;
        }

        public async Task<string> GetValueAsync(string key)
        {
            var db = _redisConnection.GetDatabase();
            return await db.StringGetAsync(key);
        }

        public async Task SetValueAsync(string key, string value)
        {
            var db = _redisConnection.GetDatabase();
            await db.StringSetAsync(key, value);
        }

        public async Task StoreSimilarityMatrixAsync(Dictionary<string, double> similarityMatrix)
        {
            var serializedMatrix = JsonSerializer.Serialize(similarityMatrix);
            await SetValueAsync("musewave:genreSimilarityMatrix", serializedMatrix);
        }
        public async Task<Dictionary<string, double>?> GetSimilarityMatrixAsync()
        {
            var serializedMatrix = await GetValueAsync("musewave:genreSimilarityMatrix");
            if (string.IsNullOrEmpty(serializedMatrix))
            {
                Console.WriteLine("No similarity matrix found in Redis.");
                return null;
            }
            return JsonSerializer.Deserialize<Dictionary<string, double>>(serializedMatrix);
        }

        public async Task AddTotalTimeListened(string userId, int timeListened)
        {
            var db = _redisConnection.GetDatabase();
            await db.StringIncrementAsync($"musewave:user:{userId}:totalTimeListened", timeListened);
        }

        public async Task<int> GetTotalTimeListened(string userId)
        {
            var db = _redisConnection.GetDatabase();
            var totalTimeListened = await db.StringGetAsync($"musewave:user:{userId}:totalTimeListened");
            return totalTimeListened.HasValue ? (int)totalTimeListened : 0;
        }

        public async Task<int> GetAllUserTotalTimeListened(int? month = null, int? year = null)
        {
            var db = _redisConnection.GetDatabase();
            var server = _redisConnection.GetServer(_redisConnection.GetEndPoints().First());

            // Define the key pattern based on the month and year parameters
            string pattern;
            if (month.HasValue && year.HasValue)
            {
                pattern = $"musewave:user:*:totalTimeListened:{year.Value}:{month.Value:D2}";
            }
            else if (year.HasValue)
            {
                pattern = $"musewave:user:*:totalTimeListened:{year.Value}:*";
            }
            else if (month.HasValue)
            {
                pattern = $"musewave:user:*:totalTimeListened:*:{month.Value:D2}";
            }
            else
            {
                pattern = "musewave:user:*:totalTimeListened";
            }

            var keys = server.Keys(pattern: pattern);
            int totalAllUsersTimeListened = 0;

            foreach (var key in keys)
            {
                var timeListened = await db.StringGetAsync(key);
                totalAllUsersTimeListened += timeListened.HasValue ? (int)timeListened : 0;
            }

            return totalAllUsersTimeListened;
        }

    }
}
