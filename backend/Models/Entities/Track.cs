using Models.Base;

namespace Models.Entities
{
    public class Track : BaseEntity
    {
        public string Title { get; set; }
        public int Duration { get; set; }
        public int? AlbumId { get; set; }
        public Album? Album { get; set; }
        public List<Like> Likes { get; set; }
        public int? GenreId { get; set; }
        public Genre? Genre { get; set; }
        public Track()
        {
            Likes = new List<Like>();
        }
    }

    public class TrackGenre
    {
        public int Id { get; set; }
        public int TrackId { get; set; }
        public Track Track { get; set; }
        public int GenreId { get; set; }
        public Genre Genre { get; set; }
    }
}
