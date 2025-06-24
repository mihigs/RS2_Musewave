using Models.Enums;

namespace Models.DTOs.Queries
{
    public class MoodTrackersQuery
    {
        public string? UserId { get; set; }
        public DateTime? RecordDate { get; set; }
        public MoodType? MoodType { get; set; }
    }

}
