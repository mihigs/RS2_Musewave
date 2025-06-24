
using Models.Entities;
using Models.Enums;

namespace Models.DTOs
{
    public class MoodTrackerDto
    {
        public string UserId { get; set; }
        public MoodType MoodType { get; set; }
        public string? Description { get; set; }
        public DateTime RecordDate { get; set; }
    }
}
