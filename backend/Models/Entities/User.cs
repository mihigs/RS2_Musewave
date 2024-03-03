using Microsoft.AspNetCore.Identity;

namespace Models.Entities
{
    public class User : IdentityUser
    {
        public virtual List<Playlist> Playlists { get; set; }
        public virtual List<Like> Likes { get; set; }
        public virtual Artist? Artist { get; set; }
        public int? ArtistId { get; set; }
        public string UserName { get; set; }

        public User()
        {
            Playlists = new List<Playlist>();
            Likes = new List<Like>();
        }
    }
}
