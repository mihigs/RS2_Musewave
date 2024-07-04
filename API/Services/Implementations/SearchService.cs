using DataContext.Repositories;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class SearchService : ISearchService
    {
        private readonly ISearchHistoryRepository _searchHistoryRepository;

        public SearchService(
            ISearchHistoryRepository searchHistoryRepository
        )
        {
            _searchHistoryRepository = searchHistoryRepository;
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
