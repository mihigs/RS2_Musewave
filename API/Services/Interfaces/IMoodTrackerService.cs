using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;

namespace Services.Interfaces
{
    public interface IMoodTrackerService
    {
        Task<MoodTracker?> CheckIfAlreadyRecorded(MoodTracker moodTracker);
        Task<IEnumerable<MoodTracker>> GetMoodTrackers(MoodTrackersQuery query);
        Task RecordMoodAsync(MoodTracker moodTrackerEntry);
    }
}
