using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.DTOs.Queries;
using Models.Entities;
using Services.Interfaces;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace Services.Implementations
{
    public class ReportingService : IReportingService
    {
        private readonly IReportingRepository _reportingRepository;
        private readonly ITrackRepository _trackRepository;
        private readonly IUserRepository _userRepository;
        private readonly IArtistRepository _artistRepository;
        private readonly IActivityRepository _activityRepository;
        private readonly IRedisService _redisService;
        private readonly IUserDonationRepository _userDonationRepository;

        public ReportingService(
            IReportingRepository reportingRepository,
            ITrackRepository trackRepository,
            IUserRepository userRepository,
            IArtistRepository artistRepository,
            IActivityRepository activityRepository,
            IRedisService redisService,
            IUserDonationRepository userDonationRepository
            )
        {
            _reportingRepository = reportingRepository;
            _trackRepository = trackRepository;
            _userRepository = userRepository;
            _artistRepository = artistRepository;
            _activityRepository = activityRepository;
            _redisService = redisService;
            _userDonationRepository = userDonationRepository;
        }

        public async Task<List<Report>> GetReportsAsync(ReportsQuery query)
        {
            return await _reportingRepository.GetReportsAsync(query);
        }

        public async Task<Report> GenerateMonthlyReportAsync(int? month = null, int? year = null)
        {
            var newReport = new Report
            {
                ReportDate = DateTime.Now,
                ReportMonth = month ?? DateTime.Now.Month,
                ReportYear = year ?? DateTime.Now.Year
            };

            var musewaveTrackCount = await _trackRepository.GetMusewaveTrackCount(newReport.ReportMonth, newReport.ReportYear);
            var jamendoTrackCount = await _trackRepository.GetJamendoTrackCount(newReport.ReportMonth, newReport.ReportYear);
            var artistCount = await _artistRepository.GetArtistCount(newReport.ReportMonth, newReport.ReportYear);
            var userCount = await _userRepository.GetUserCount(withArtists: false, newReport.ReportMonth, newReport.ReportYear);
            var dailyLoginCount = await _activityRepository.GetDailyLoginCount(newReport.ReportMonth, newReport.ReportYear);
            var jamendoApiActivity = await _activityRepository.GetJamendoAPIRequestCountPerMonth(newReport.ReportMonth, newReport.ReportYear);
            var totalTimeListened = await _redisService.GetAllUserTotalTimeListened(newReport.ReportMonth, newReport.ReportYear);
            var allDonations = _userDonationRepository.GetAll().Result.Where(x => x.CreatedAt.Month == newReport.ReportMonth && x.CreatedAt.Year == newReport.ReportYear).ToList();
            decimal totalDonationsAmount = allDonations.Sum(x => x.Amount) / 100;
            var totalDonationsCount = allDonations.Count();

            newReport.NewMusewaveTrackCount = musewaveTrackCount;
            newReport.NewJamendoTrackCount = jamendoTrackCount;
            newReport.NewUserCount = userCount;
            newReport.NewArtistCount = artistCount;
            newReport.DailyLoginCount = dailyLoginCount;
            newReport.MonthlyJamendoApiActivity = jamendoApiActivity;
            newReport.MonthlyTimeListened = totalTimeListened;
            newReport.MonthlyDonationsAmount = totalDonationsAmount;
            newReport.MonthlyDonationsCount = totalDonationsCount;

            await _reportingRepository.Add(newReport);

            return newReport;
        }

        public async Task<byte[]> ExportReportAsPDF(int reportId)
        {
            // Retrieve the report from the database
            var report = await _reportingRepository.GetById(reportId);
            if (report == null)
            {
                throw new Exception("Report not found");
            }

            // Generate the PDF document
            var pdfBytes = GenerateReportPdf(report);

            return pdfBytes;
        }

        // Helper method to generate the PDF
        private byte[] GenerateReportPdf(Report report)
        {
            var document = QuestPDF.Fluent.Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(2, Unit.Centimetre);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(12));

                    page.Header()
                        .Text($"Report for {MonthName(report.ReportMonth)} {report.ReportYear}")
                        .SemiBold().FontSize(20).FontColor(Colors.Blue.Medium);

                    page.Content()
                        .PaddingVertical(1, Unit.Centimetre)
                        .Column(column =>
                        {
                            column.Spacing(5);

                            column.Item().Text($"Report Date: {report.ReportDate.ToString("yyyy-MM-dd HH:mm")}");
                            column.Item().Text($"New Musewave Tracks: {report.NewMusewaveTrackCount}");
                            column.Item().Text($"New Jamendo Tracks: {report.NewJamendoTrackCount}");
                            column.Item().Text($"New Users: {report.NewUserCount}");
                            column.Item().Text($"New Artists: {report.NewArtistCount}");
                            column.Item().Text($"Daily Logins: {report.DailyLoginCount}");
                            column.Item().Text($"Monthly Jamendo API Activity: {report.MonthlyJamendoApiActivity}");
                            column.Item().Text($"Monthly Time Listened: {report.MonthlyTimeListened}");
                            column.Item().Text($"Monthly Donations Amount: {report.MonthlyDonationsAmount:C}");
                            column.Item().Text($"Monthly Donations Count: {report.MonthlyDonationsCount}");
                        });

                    page.Footer()
                        .AlignCenter()
                        .Text(x =>
                        {
                            x.Span("Page ");
                            x.CurrentPageNumber();
                            x.Span(" of ");
                            x.TotalPages();
                        });
                });
            });

            // Generate the PDF and return as byte array
            return document.GeneratePdf();
        }

        private string MonthName(int month)
        {
            return new DateTime(1, month, 1).ToString("MMMM");
        }
    }
}
