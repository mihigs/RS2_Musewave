using Microsoft.AspNetCore.Identity;

namespace Models
{
    public class Artist : IdentityUser
    {
        public List<Album> Albums { get; set; }
    }
}
