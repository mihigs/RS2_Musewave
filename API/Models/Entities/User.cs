using Microsoft.AspNetCore.Identity;

namespace Models.Entities
{
    public class User : IdentityUser
    {
        public virtual List<Like> Likes { get; set; }
        public virtual Artist? Artist { get; set; }
        public int? ArtistId { get; set; }
        public string UserName { get; set; }
        public int LanguageId { get; set; }
        public Language Language { get; set; }

        public User()
        {
            Likes = new List<Like>();
        }
    }
}
