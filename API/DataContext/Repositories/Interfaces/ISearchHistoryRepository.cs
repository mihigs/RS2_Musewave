using Models.Entities;

namespace DataContext.Repositories;
public interface ISearchHistoryRepository : IRepository<SearchHistory>
{
    Task<IEnumerable<SearchHistory>> GetSearchHistorysAsync(string userId);
}