using Models.DTOs.Queries;
using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IMoodTrackerRepository : IRepository<MoodTracker>
    {
        //Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name);
        //Task<Artist> GetArtistByUserId(string userId);
        //Task<int> GetArtistCount(int? month = null, int? year = null);
        //Task<Artist?> GetArtistByJamendoId(string jamendoArtistId);
        //Task<Artist> GetArtistDetailsAsync(int artistId);
        Task<MoodTracker?> GetDuplicateRecord(string userId, DateTime recordDate);
        Task<IEnumerable<MoodTracker>> GetMoodTrackers(MoodTrackersQuery moodTrackersQuery);

    }
}
