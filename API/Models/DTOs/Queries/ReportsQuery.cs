namespace Models.DTOs.Queries
{
    public class ReportsQuery
    {
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int? Month { get; set; }
        public int? Year { get; set; }
    }

}
