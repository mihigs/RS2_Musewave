namespace Services.Interfaces
{
    public interface IRedisService
    {
        Task<string> GetValueAsync(string key);
        Task SetValueAsync(string key, string value);
        Task StoreSimilarityMatrixAsync(Dictionary<string, double> similarityMatrix);
        Task<Dictionary<string, double>?> GetSimilarityMatrixAsync();
    }
}