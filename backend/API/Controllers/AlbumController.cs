using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;
using System.Security.Claims;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AlbumController : ControllerBase
    {
        private readonly IAlbumService _albumService;

        public AlbumController(IAlbumService albumService)
        {
            _albumService = albumService ?? throw new ArgumentNullException(nameof(albumService));
        }

        [HttpGet]
        public async Task<ApiResponse> GetAllAlbums()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _albumService.GetAllAlbumsAsync();
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }

        [HttpGet("{id}")]
        public async Task<ApiResponse> GetAlbumById(int id)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _albumService.GetAlbumByIdAsync(id);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }

        [HttpPost]
        public async Task<ApiResponse> AddAlbum(Album album)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var addedAlbum = await _albumService.AddAlbumAsync(album);
                apiResponse.Data = addedAlbum;
                apiResponse.StatusCode = System.Net.HttpStatusCode.Created;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse> UpdateAlbum(int id, Album album)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var updatedAlbum = await _albumService.UpdateAlbumAsync(album);
                apiResponse.Data = updatedAlbum;
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse> RemoveAlbum(int id)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var removedAlbum = await _albumService.RemoveAlbumAsync(id);
                if (removedAlbum == null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    return apiResponse;
                }
                apiResponse.Data = removedAlbum;
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }

        [HttpGet("GetAlbumsByTitle")]
        public async Task<ApiResponse> GetAlbumsByTitle(string title)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _albumService.GetAlbumsByTitleAsync(title);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }

        [HttpGet("GetAlbumDetails/{albumId}")]
        public async Task<ApiResponse> GetAlbumDetails(int albumId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                // gets the user id from the token
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim == null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return apiResponse;
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _albumService.GetAlbumDetails(albumId, userId);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }
    }
}
