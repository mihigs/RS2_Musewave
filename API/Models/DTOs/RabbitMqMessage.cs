namespace Models.DTOs
{
    public class RabbitMqMessage
    {
        public string ArtistId { get; set; }
        public string TrackId { get; set; }
        public string Payload { get; set; }
        public int Duration { get; set; }
        public string UserId { get; set; }
    }
}
