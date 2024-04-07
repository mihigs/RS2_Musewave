using Models.Entities;
using System.Net;

namespace Models.DTOs
{
    public class UserPlaylistsDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public virtual List<int> TrackIds { get; set; } = new List<int>();
        public bool IsPublic { get; set; }
        public bool IsExploreWeekly { get; set; }

        public UserPlaylistsDto(Playlist playlist)
        {
            Id = playlist.Id;
            Name = playlist.Name;
            UserId = playlist.UserId;
            User = playlist.User;
            TrackIds = playlist.Tracks.Select(pt => pt.TrackId).ToList();
            IsPublic = playlist.IsPublic;
            IsExploreWeekly = playlist.IsExploreWeekly;
        }
    }
}
