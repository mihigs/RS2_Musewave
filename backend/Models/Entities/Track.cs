using Models.Base;

namespace Models.Entities
{
    public class Track : BaseEntity
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
        public string? JamendoId { get; set; }
    }

    public class TrackGenre
    {
        public int Id { get; set; }
        public int TrackId { get; set; }
        public virtual Track Track { get; set; }
        public int GenreId { get; set; }
        public virtual Genre Genre { get; set; }
    }

}
