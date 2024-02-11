using Microsoft.AspNetCore.Identity;

namespace Models
{
    public class User : IdentityUser
    {
        public List<Playlist> Playlists { get; set; }
        public List<Like> Likes { get; set; }
    }
}
