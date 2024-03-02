using System.ComponentModel;

namespace Models.DTOs
{
    public class UserLogin
    {
        [DefaultValue("admin@musewave.com")] // todo: remove this
        public string Email { get; set; }

        [DefaultValue("Test_123")]
        public string Password { get; set; }
    }
}
