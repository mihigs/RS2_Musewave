using Models.Base;

namespace Models.Entities
{
    public class Artist : BaseEntity
    {
        public string UserId { get; set; }
        public virtual User User { get; set; }
        public virtual List<Album> Albums { get; set; }
        public virtual List<Track> Tracks { get; set; }

        public Artist()
        {
            Albums = new List<Album>();
            Tracks = new List<Track>();
        }
    }
}
