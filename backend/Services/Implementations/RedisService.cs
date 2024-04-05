using Azure;
using Services.Interfaces;
using StackExchange.Redis;
using static Models.DTOs.JamendoApiDto;
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

    }
}
