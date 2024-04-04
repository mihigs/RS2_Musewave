using Models.Base;

namespace Models.Entities
{
    public class Album : BaseEntity
    {
        public string Title { get; set; }
        public int ArtistId { get; set; }
        public virtual Artist Artist { get; set; }
        public virtual List<Track> Tracks { get; set; }

        public Album()
        {
            Tracks = new List<Track>();
        }
    }
}
