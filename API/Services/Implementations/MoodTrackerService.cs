using DataContext.Repositories.Interfaces;
using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;
using Services.Interfaces;

namespace Services.Implementations
{
    public class MoodTrackerService : IMoodTrackerService
    {
        private readonly IMoodTrackerRepository _moodTrackerRepository;

        public MoodTrackerService(IMoodTrackerRepository moodTrackerRepository)
        {
            _moodTrackerRepository = moodTrackerRepository;
        }

        public async Task<MoodTracker?> CheckIfAlreadyRecorded(MoodTracker moodTracker)
        {
            return await _moodTrackerRepository.GetDuplicateRecord(moodTracker.UserId, moodTracker.RecordDate);
        }

        public async Task<IEnumerable<MoodTracker>> GetMoodTrackers(MoodTrackersQuery query)
        {
            return await _moodTrackerRepository.GetMoodTrackers(query);
        }

        public async Task RecordMoodAsync(MoodTracker moodTrackerEntry)
        {
            var existingRecord = await CheckIfAlreadyRecorded(moodTrackerEntry);

            if (existingRecord != null)
            {
                throw new Exception("Mood already recorded");
            }

            await _moodTrackerRepository.Add(moodTrackerEntry);
        }

        //public async Task<IEnumerable<Artist>> GetArtistsAsync(ArtistQuery query)
        //{
        //    var results = new List<Artist>();

        //    if (!string.IsNullOrEmpty(query.Name))
        //    {
        //        var artistsByName = await GetArtistsByNameAsync(query.Name);
        //        results.AddRange(artistsByName);
        //    }

        //    // Remove duplicates if any
        //    return results.Distinct().ToList();
        //}

        //public async Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name)
        //{
        //    return await _moodTrackerRepository.GetArtistsByNameAsync(name);
        //}

        //public async Task<ArtistDetailsDto> GetArtistDetailsAsync(int artistId, bool isJamendoArtist)
        //{
        //    var result = new ArtistDetailsDto();

        //    if (isJamendoArtist)
        //    {
        //        result = await _jamendoService.GetJamendoArtistDetails(artistId.ToString());
        //    }
        //    else
        //    {
        //        result.Artist = await _moodTrackerRepository.GetArtistDetailsAsync(artistId);
        //        result.Tracks = await _trackRepository.GetTracksByArtistId(artistId);
        //        result.Tracks = result.Tracks.Select(track =>
        //        {
        //            track.SignedUrl = _tracksService.GenerateSignedTrackUrl(track.FilePath, track.ArtistId.ToString());
        //            return track;
        //        }).ToList();

        //    }

        //    return result;
        //}

    }
}
