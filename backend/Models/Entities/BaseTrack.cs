using Models.Base;

namespace Models.Entities
{
    public class BaseTrack : BaseEntity
    {
        public string Title { get; set; }
        public int Duration { get; set; }
        public int? AlbumId { get; set; }
        public virtual Album? Album { get; set; }
        public virtual List<Like> Likes { get; set; } = new List<Like>();
        public virtual ICollection<TrackGenre> TrackGenres { get; set; } = new List<TrackGenre>();
        public virtual Artist Artist { get; set; }
        public int ArtistId { get; set; }
        public string? FilePath { get; set; }
        public string? SignedUrl { get; set; }
        public bool? IsLiked { get; set; }
        public string? ImageUrl { get; set; }
    }

    public class TrackGenre
    {
        public int Id { get; set; }
        public int TrackId { get; set; }
        public virtual BaseTrack Track { get; set; }
        public int GenreId { get; set; }
        public virtual Genre Genre { get; set; }
    }

    public class Track : BaseTrack
    {
        public string? JamendoId { get; set; }

        public static Track FromBaseTrack(BaseTrack baseTrack)
        {
            return new Track
            {
                Id = baseTrack.Id,
                Title = baseTrack.Title,
                Duration = baseTrack.Duration,
                AlbumId = baseTrack.AlbumId,
                Album = baseTrack.Album,
                Likes = baseTrack.Likes,
                TrackGenres = baseTrack.TrackGenres,
                Artist = baseTrack.Artist,
                ArtistId = baseTrack.ArtistId,
                FilePath = baseTrack.FilePath,
                SignedUrl = baseTrack.SignedUrl,
                IsLiked = baseTrack.IsLiked,
                ImageUrl = baseTrack.ImageUrl,
                JamendoId = null
            };
        }
    }
}
