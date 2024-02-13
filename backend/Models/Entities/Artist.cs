using Models.Base;

namespace Models.Entities
{
    public class Artist : BaseEntity
    {
        public string UserId { get; set; }
        public User User { get; set; }
        public List<Album> Albums { get; set; }
        public List<Track> Tracks { get; set; }

        public Artist()
        {
            Albums = new List<Album>();
            Tracks = new List<Track>();
        }
    }
}
