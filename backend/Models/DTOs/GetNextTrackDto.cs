using Models.Enums;

namespace Models.DTOs
{
    public class GetNextTrackRequestDto
    {
        public int CurrentTrackId { get; set; }
        public int? ContextId { get; set; }
        public StreamingContextType StreamingContextType { get; set; }
        public List<int> TrackHistoryIds { get; set; }

        public GetNextTrackRequestDto()
        {
            TrackHistoryIds = new List<int>();
        }
    }
    public class GetNextTrackResponseDto
    {
        public int CurrentTrackId { get; set; }
        public int? ContextId { get; set; }
        public StreamingContextType StreamingContextType { get; set; }
        public List<int> TrackHistoryIds { get; set; }

        public GetNextTrackResponseDto()
        {
            TrackHistoryIds = new List<int>();
        }
    }
}
