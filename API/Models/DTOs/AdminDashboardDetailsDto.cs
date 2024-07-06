namespace Models.DTOs
{
    public class AdminDashboardDetailsDto
    {
        public int MusewaveTrackCount { get; set; }
        public int JamendoTrackCount { get; set; }
        public int UserCount { get; set; }
        public int ArtistCount { get; set; }
        public int DailyLoginCount { get; set; }
        public int JamendoApiActivity { get; set; }
        public int TotalTimeListened { get; set; }
        public decimal TotalDonationsAmount { get; set; }
        public int TotalDonationsCount { get; set; }
    }
}
