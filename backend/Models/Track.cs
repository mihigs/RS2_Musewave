using Models.Base;

namespace Models
{
    public class Track : BaseEntity
    {
        public string Title { get; set; }
        public int Duration { get; set; }
        public int AlbumId { get; set; }
        public Album Album { get; set; }
    }
}
