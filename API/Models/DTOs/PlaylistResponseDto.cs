using Models.Entities;

namespace Models.DTOs
{
    public class PlaylistResponseDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public virtual List<Track> Tracks { get; set; }
        public bool IsPublic { get; set; }
        public bool IsExploreWeekly { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        public PlaylistResponseDto(Playlist playlist)
        {
            Id = playlist.Id;
            Name = playlist.Name;
            UserId = playlist.UserId;
            User = playlist.User;
            Tracks = playlist.Tracks.Select(pt => pt.Track).ToList();
            IsPublic = playlist.IsPublic;
            IsExploreWeekly = playlist.IsExploreWeekly;
            CreatedAt = playlist.CreatedAt;
            UpdatedAt = playlist.UpdatedAt;
        }
    }
}
