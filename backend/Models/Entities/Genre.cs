using Models.Base;

namespace Models.Entities
{
    public class Genre : BaseEntity
    {
        public string Name { get; set; }
        public virtual ICollection<TrackGenre> TrackGenres { get; set; } = new List<TrackGenre>();
    }
}
