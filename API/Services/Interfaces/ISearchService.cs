using Models.Entities;

namespace Services.Interfaces
{
    public interface ISearchService
    {
        Task<IEnumerable<SearchHistory>> GetSearchHistorysAsync(string userId);
        Task LogSearchRequestAsync(string searchTerm, string userId);
        Task RemoveSearchHistoryAsync(int searchHistoryId);
    }
}
