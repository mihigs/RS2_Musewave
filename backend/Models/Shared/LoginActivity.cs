namespace Models.Shared
{
    public class LoginActivity : BaseEntity
    {
        public string Email { get; set; }
        public bool Success { get; set; }
        public DateTimeOffset Timestamp { get; set; } = DateTimeOffset.Now;
    }
}
