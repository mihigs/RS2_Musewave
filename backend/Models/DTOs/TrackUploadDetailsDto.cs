using Models.Enums;

namespace Models.DTOs
{
    public class GetNextTrackDto
    {
        public int CurrentTrackId { get; set; }
        public int? ContextId { get; set; }
        public StreamingContextType StreamingContextType { get; set; }
        public List<int> TrackHistoryIds { get; set; }

        public GetNextTrackDto()
        {
            TrackHistoryIds = new List<int>();
        }
    }
}
