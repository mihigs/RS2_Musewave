using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.DTOs.Queries;
using Models.Entities;

namespace DataContext.Repositories
{
    public class ReportingRepository : Repository<Report>, IReportingRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public ReportingRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<List<Report>> GetReportsAsync(ReportsQuery query)
        {
            var reports = _dbContext.Reports.AsQueryable();

            if (query.StartDate.HasValue)
            {
                reports = reports.Where(r => r.ReportDate >= query.StartDate.Value);
            }

            if (query.EndDate.HasValue)
            {
                reports = reports.Where(r => r.ReportDate <= query.EndDate.Value);
            }

            if (query.Month.HasValue)
            {
                reports = reports.Where(r => r.ReportMonth == query.Month.Value);
            }

            if (query.Year.HasValue)
            {
                reports = reports.Where(r => r.ReportYear == query.Year.Value);
            }

            return await reports.ToListAsync();
        }


    }
}
