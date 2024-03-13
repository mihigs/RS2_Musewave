using Listener.Models.DTOs;
using Listener.Services;
using Microsoft.AspNetCore.Mvc;

namespace Listener
{
    [Route("api/[controller]")]
    [ApiController]
    public class TracksController : ControllerBase
    {
        private readonly ITrackService _trackService;

        public TracksController(ITrackService trackService)
        {
            _trackService = trackService;
        }

        [HttpPost("UploadTrack")]
        public async Task<IActionResult> UploadTrack(TrackUploadDto model)
        {
            // Check if file is not empty
            if (model.mediaFile == null || model.mediaFile.Length == 0)
            {
                return BadRequest("File cannot be empty");
            }
            // Check if trackName is not empty
            if (string.IsNullOrWhiteSpace(model.trackName))
            {
                return BadRequest("Track name cannot be empty");
            }
            // Check if userId is not empty
            if (string.IsNullOrWhiteSpace(model.userId))
            {
                return BadRequest("User ID cannot be empty");
            }
            // Check if file size is less than 10MB
            if (model.mediaFile.Length > 10 * 1024 * 1024) // 10MB in bytes
            {
                return BadRequest("File size cannot exceed 10MB");
            }

            // Check if file type is .mp3, .midi, .mid or .wav
            var allowedExtensions = new[] { ".mp3", ".midi", ".mid", ".wav" };
            var fileExtension = Path.GetExtension(model.mediaFile.FileName).ToLower();

            if (!allowedExtensions.Contains(fileExtension))
            {
                return BadRequest("Invalid file type. Only .mp3, .midi, .mid and .wav files are allowed");
            }

            // If file is valid, send it to the TrackService to be processed
            _trackService.ProcessTrack(model);

            // Return a 201 Created response
            return CreatedAtAction(nameof(UploadTrack), new { fileName = model.mediaFile.FileName });
        }


        //[HttpGet]
        //public async Task<ActionResult<IEnumerable<Track>>> GetTracks()
        //{
        //    return await _trackService.GetTracks();
        //}

        //[HttpGet("{id}")]
        //public async Task<ActionResult<Track>> GetTrack(int id)
        //{
        //    var track = await _trackService.GetTrack(id);

        //    if (track == null)
        //    {
        //        return NotFound();
        //    }

        //    return track;
        //}

        //[HttpPut("{id}")]
        //public async Task<IActionResult> PutTrack(int id, Track track)
        //{
        //    if (id != track.Id)
        //    {
        //        return BadRequest();
        //    }

        //    try
        //    {
        //        await _trackService.UpdateTrack(track);
        //    }
        //    catch (DbUpdateConcurrencyException)
        //    {
        //        if (!await _trackService.TrackExists(id))
        //        {
        //            return NotFound();
        //        }
        //        else
        //        {
        //            throw;
        //        }
        //    }

        //    return NoContent();
        //}

        //[HttpPost]
        //public async Task<ActionResult<Track>> PostTrack(Track track)
        //{
        //    await _trackService.AddTrack(track);

        //    return CreatedAtAction("GetTrack", new { id = track.Id }, track);
        //}

        //[HttpDelete("{id}")]
        //public async Task<ActionResult<Track>> DeleteTrack(int id)
        //{
        //    var track = await _trackService.DeleteTrack(id);
        //    if (track == null)
        //    {
        //        return NotFound();
        //    }

        //    return track;
        //}
    }
}
