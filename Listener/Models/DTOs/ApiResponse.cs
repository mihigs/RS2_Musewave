using System.Net;

namespace Listener.Models.DTOs
{
    public class ApiResponse
    {
        public HttpStatusCode StatusCode { get; set; }
        public IList<string> Errors { get; set; } = new List<string>();
        public dynamic Data { get; set; }
    }
}
