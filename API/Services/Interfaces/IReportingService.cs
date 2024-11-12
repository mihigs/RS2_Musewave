using Models.DTOs.Queries;
using Models.Entities;

namespace Services.Interfaces
{
    public interface IReportingService
    {
        Task<List<Report>> GetReportsAsync(ReportsQuery query);
        Task<Report> GenerateMonthlyReportAsync(int? month = null, int? year = null);
        Task<byte[]> ExportReportAsPDF(int reportId);
    }
}
