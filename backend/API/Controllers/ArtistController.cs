using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ArtistController : ControllerBase
    {
        private readonly IArtistService _artistService;

        public ArtistController(IArtistService artistService)
        {
            _artistService = artistService ?? throw new ArgumentNullException(nameof(artistService));
        }

        //[HttpGet]
        //public async Task<ApiResponse> GetAllArtists()
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        apiResponse.Data = await _artistService.GetAllArtistsAsync();
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        //[HttpGet("{id}")]
        //public async Task<ApiResponse> GetArtistById(int id)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        apiResponse.Data = await _artistService.GetArtistByIdAsync(id);
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        //[HttpPost]
        //public async Task<ApiResponse> AddArtist(Artist artist)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var addedArtist = await _artistService.AddArtistAsync(artist);
        //        apiResponse.Data = addedArtist;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.Created;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        //[HttpPut("{id}")]
        //public async Task<ApiResponse> UpdateArtist(int id, Artist artist)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var updatedArtist = await _artistService.UpdateArtistAsync(artist);
        //        apiResponse.Data = updatedArtist;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        //[HttpDelete("{id}")]
        //public async Task<ApiResponse> RemoveArtist(int id)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var removedArtist = await _artistService.RemoveArtistAsync(id);
        //        if (removedArtist is null)
        //        {
        //            apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
        //            return apiResponse;
        //        }
        //        apiResponse.Data = removedArtist;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        [HttpGet("GetArtistsByName")]
        public async Task<ApiResponse> GetArtistsByName(string name)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _artistService.GetArtistsByNameAsync(name);
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
