using Models.DTOs.Queries;
using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IReportingRepository : IRepository<Report>
    {
        Task<List<Report>> GetReportsAsync(ReportsQuery query);
    }
}
