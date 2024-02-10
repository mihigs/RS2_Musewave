using Microsoft.AspNetCore.Mvc;
using Models;
using Services.Implementations;

namespace API.Controllers
{
    //[Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AlbumsController : ControllerBase
    {
        private readonly AlbumService _albumService;

        public AlbumsController(AlbumService albumService)
        {
            _albumService = albumService ?? throw new ArgumentNullException(nameof(albumService));
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Album>>> GetAllAlbums()
        {
            var albums = await _albumService.GetAllAlbumsAsync();
            return Ok(albums);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Album>> GetAlbumById(int id)
        {
            var album = await _albumService.GetAlbumByIdAsync(id);
            if (album == null)
                return NotFound();

            return Ok(album);
        }

        [HttpPost]
        public async Task<ActionResult<Album>> AddAlbum(Album album)
        {
            try
            {
                var addedAlbum = await _albumService.AddAlbumAsync(album);
                return CreatedAtAction(nameof(GetAlbumById), new { id = addedAlbum.Id }, addedAlbum);
            }
            catch (Exception ex)
            {
                // Handle any validation or other exceptions
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<Album>> UpdateAlbum(int id, Album album)
        {
            if (id != album.Id)
                return BadRequest("Album ID mismatch");

            try
            {
                var updatedAlbum = await _albumService.UpdateAlbumAsync(album);
                return Ok(updatedAlbum);
            }
            catch (Exception ex)
            {
                // Handle any validation or other exceptions
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<Album>> RemoveAlbum(int id)
        {
            var removedAlbum = await _albumService.RemoveAlbumAsync(id);
            if (removedAlbum == null)
                return NotFound();

            return Ok(removedAlbum);
        }
    }
}
