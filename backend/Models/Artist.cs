using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models
{
    public class Artist
    {
        public string ArtistId { get; set; }

        public User User { get; set; }

        public List<Album> Albums { get; set; }
    }
}
