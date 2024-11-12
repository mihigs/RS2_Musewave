using Models.Base;

namespace Models.Entities
{
    public class Report : BaseEntity
    {
        public int NewMusewaveTrackCount { get; set; }
        public int NewJamendoTrackCount { get; set; }
        public int NewUserCount { get; set; }
        public int NewArtistCount { get; set; }
        public int DailyLoginCount { get; set; }
        public int MonthlyJamendoApiActivity { get; set; }
        public int MonthlyTimeListened { get; set; }
        public decimal MonthlyDonationsAmount { get; set; }
        public int MonthlyDonationsCount { get; set; }
        public int ReportMonth { get; set; }
        public int ReportYear { get; set; }
        public DateTime ReportDate { get; set; }
    }
}
