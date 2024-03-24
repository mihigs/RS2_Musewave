using Microsoft.AspNetCore.Mvc;

namespace Listener
{
    [Route("api/[controller]")]
    [ApiController]
    public class HealthCheckController : ControllerBase
    {
        [HttpGet]
        public IActionResult Get() => Ok("Running");
    }
}
