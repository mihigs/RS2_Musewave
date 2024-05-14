using Models.Base;

namespace Models.Entities
{
    public class Artist : BaseEntity
    {
        public string UserId { get; set; }
        public string? JamendoArtistId { get; set; }
        public string? ArtistImageUrl { get; set; }
        public virtual User User { get; set; }
    }
}
